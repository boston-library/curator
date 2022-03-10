# frozen_string_literal: true

module Curator
  module Filestreams
    module Attacher
      extend ActiveSupport::Concern
      # TODO: figure out a way to call attach without invoking ActiveStorage::AnalyzeJob
      # We can invoke NullAnalyzer by setting below in config/application.rb:
      #   config.active_storage.analyzers = []
      #   config.active_storage.previewers = []
      # However, even if we do above, ActiveStorage will compute byte_size, content_type, and checksum anyway
      included do
        include AttacherUtils
        include InstanceMethods
      end

      module InstanceMethods
        protected

        def attach_files!(record)
          files = @json_attrs.fetch('files', [])

          return if files.blank?

          attachments = files.group_by { |file_hash| file_hash['file_type'].underscore }

          attachment_types_for_blob = record_attachments(record).select { |at| attachments.key?(at) }

          attachment_types_for_blob.each_slice(ENV.fetch('RAILS_MAX_THREADS', 5)) do |attachment_types|
            attachment_futures = attachment_types.map do |attachment_type|
              Concurrent::Promises.future(record, attachment_type, attachments) do |rec, attch_type, attchmnts|
                Rails.application.executor.wrap do
                  attach_group!(rec, attch_type, attchmnts[attch_type])
                end
              end
            end
            ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
              attachment_futures.each(&:value!)
            end
          end
        end

        def attach_group!(record, attachment_type, attachments = [])
          return if attachments.blank?

          attachments.each do |attachment|
            attributes = file_attributes(attachment)

            io_hash = attachment.fetch('io', {})
            io_hash['ingest_filepath'] = attributes['metadata']['ingest_filepath'] if attributes.dig('metadata', 'ingest_filepath').present?

            attachment_file_key = file_key_for_service(record, attachment_type, attributes['file_name'], attributes['content_type'])
            attributes['key'] = attachment_file_key if !attributes.key?('key')
            raise ActiveStorage::Error, "improper format for key #{attributes['key']}" if attributes['key'] != attachment_file_key

            attributes['service_name'] = attachment_service(record, attachment_type)

            attachable = if record.public_send(attachment_type).attached?
                           update_attachable(record.public_send("#{attachment_type}_blob"), attributes, io_hash)
                         else
                           create_attachable(attributes, io_hash)
                         end

            record.public_send(attachment_type).attach(attachable)

            check_file_fixity!(record.public_send(attachment_type), attributes['byte_size'], attributes['checksum_md5'])
          end
        end

        # @param attributes [Hash]
        # @param io_hash [Hash
        # @returns [ActiveStorage::Blob]
        def create_attachable(attributes, io_hash = {})
          return attach_existing_file(attributes) if io_hash.blank?

          return import_file_from_fedora(attributes, content_io(io_hash)) if fedora_content?(io_hash)

          # NOTE we should be passing a Hash to the attach method. This is more in line with what vanilla active storage does and will cut back on errors. See this file for more info https://github.com/rails/rails/blob/e3e3a97ada3f2b4c0c8d48f941c2ea05c859cdda/activestorage/lib/active_storage/attached/changes/create_one.rb#L52
          {
            key: attributes['key'],
            io: content_io(io_hash),
            service_name: attributes['service_name'],
            filename: attributes['file_name'],
            content_type: attributes['content_type'],
            metadata: attributes['metadata'],
            identify: attributes['content_type'].present? # This is specified here https://github.com/rails/rails/blob/8929f6f6e492c15a58ca13290f5ff44d00b37ccc/activestorage/app/models/active_storage/blob.rb#L110
          }
        end

        # @param blob [ActiveStorage::Blob]
        # @param attributes [Hash]
        # @param io_hash [Hash]
        # @returns [ActiveStorage::Blob]
        def update_attachable(blob, attributes, io_hash = {})
          return attach_existing_file(attributes) if io_hash.blank?

          return import_file_from_fedora(attributes, content_io(io_hash)) if fedora_content?(io_hash)

          attachment_attributes = attributes.slice('file_name', 'byte_size', 'content_type', 'metadata')
          attachment_attributes['filename'] = attachment_attributes.delete('file_name') if attachment_attributes['file_name']
          attachment_attributes['checksum_md5'] = checksum_to_base64(attributes['checksum_md5']) if attributes['checksum_md5']

          blob.upload(content_io(io_hash), identify: false) if blob.update!(attachment_attributes)

          blob
        end

        def file_attributes(attachment = {})
          attachment.slice('key', 'created_at', 'file_name', 'content_type', 'byte_size', 'checksum_md5').merge('metadata' => attachment.fetch('metadata', {}))
        end

        def fedora_content?(io = {})
          io.dig('fedora_content_location').present?
        end

        def uploaded_file_content?(io = {})
          io.dig('uploaded_file').present?
        end

        def ingest_content?(io = {})
          io.dig('ingest_filepath').present?
        end

        private

        # @param attachment_attributes [Hash]
        # @param io [Tempfile]
        # @returns [ActiveStorage::Blob]
        def import_file_from_fedora(attachment_attributes, io)
          ActiveStorage::Blob.find_or_initialize_by(key: attachment_attributes['key']).tap do |blob|
            blob.filename =  attachment_attributes['file_name']
            blob.byte_size = attachment_attributes['byte_size']
            blob.checksum = checksum_to_base64(attachment_attributes['checksum_md5'])
            blob.content_type = attachment_attributes['content_type']
            blob.service_name = attachment_attributes['service_name']
            blob.metadata = attachment_attributes['metadata']&.merge(analyzed: true)
          end.tap(&:save!).tap do |blob|
            blob.upload_without_unfurling(io)
          end
        end

        # @param attachment_attributes [Hash]]
        # @returns [ActiveStorage::Blob]
        def attach_existing_file(attachment_attributes)
          blob = ActiveStorage::Blob.find_or_initialize_by(key: attachment_attributes['key']).tap do |b|
            b.filename = attachment_attributes['file_name']
            b.byte_size = attachment_attributes['byte_size']
            b.checksum = attachment_attributes['checksum_md5']
            b.content_type = attachment_attributes['content_type']
            b.service_name = attachment_attributes['service_name']
            b.metadata = attachment_attributes['metadata']
            b.save!
          end

          return blob if blob.uploaded?

          raise ActiveStorage::FileNotFoundError, "File at #{blob.key} in service #{blob.service_name} not found!"
        end

        def record_attachments(record)
          record.class.attachment_reflections.keys
        end

        def attachment_service(record, attachment_type)
          attachment_options = record.class.attachment_reflections[attachment_type.to_s].options

          attachment_options[:service_name] || Rails.application.config.active_storage.service
        end
      end
    end

    module AttacherUtils
      extend ActiveSupport::Concern

      included do
        include InstanceMethods
      end

      module InstanceMethods
        protected

        def file_key_for_service(record, attachment_type, file_name, content_type)
          raise ActiveStorage::Error, 'Record identifier not present!' if record&.ark_id.blank?

          record_type = record.class.name.demodulize.downcase.pluralize

          raise ActiveStorage::Error, "Invalid Record Type #{record_type}" if !%w(institutions audios documents ereaders images metadata texts videos).include?(record_type)

          "#{record_type}/#{record.ark_id}/#{attachment_type}#{file_extension(file_name, content_type)}"
        end

        def file_extension(file_name, content_type)
          filename = ActiveStorage::Filename.wrap(file_name)

          extension = filename.extension_with_delimiter

          extension = MIME::Types[content_type]&.first&.preferred_extension if extension.blank?

          return extension if extension.present?

          raise ActiveStorage::Error, 'Could not determine mime type for image!'
        end

        # use fedora content URL if available, or local filepath, or base64 string
        def content_io(io_hash)
          return if io_hash.blank?

          return fedora_io(io_hash['fedora_content_location']) if fedora_content?(io_hash)

          return uploaded_file_io(io_hash['uploaded_file']) if uploaded_file_content?(io_hash)

          return file_path_io(io_hash['ingest_filepath']) if ingest_content?(io_hash)

          raise ActiveRecord::RecordNotSaved, "Unknown content for io #{type}"
        end

        # check ActiveStorage blob attributes against Fedora-exported data, throw error if mismatch
        # @param blob [ActiveStorage::Blob]
        # @param byte_size [Integer] size from incoming file
        # @param checksum_md5 [String] md5 checksum from incoming file
        def check_file_fixity!(blob, byte_size, checksum_md5)
          return if byte_size.blank? && checksum_md5.blank?

          validate_byte_size!(blob, byte_size) if byte_size

          validate_checksum_md5!(blob, checksum_md5) if checksum_md5
        end

        private

        def validate_byte_size!(blob, byte_size)
          return if blob.byte_size == byte_size.to_i

          raise ActiveStorage::IntegrityError,
                "FILE SIZE MISMATCH FOR ActiveStorage::Blob: #{blob.id}, blob byte size is #{blob.byte_size} vs expected #{byte_size}"
        end

        def validate_checksum_md5!(blob, checksum_md5)
          formatted_checksum = checksum_to_base64(checksum_md5)

          return if blob.checksum == formatted_checksum

          raise ActiveStorage::IntegrityError,
                "CHECKSUM MISMATCH FOR ActiveStorage::Blob: #{blob.id}, blob checksum is #{blob.checksum} VS expected #{formatted_checksum}"
        end

        # Checksums need to be base64 encoded based on how ActiveStorage works.
        # The following method checks if the checksum does not match the hex pattern
        # (assuming imported files will be mostly hex values) and encodes it to base64
        def checksum_to_base64(checksum_md5)
          return checksum_md5 if !checksum_md5.match?(/^[[:xdigit:]]+$/)

          Base64.strict_encode64([checksum_md5].pack('H*'))
        end

        def file_path_io(ingest_filepath)
          return if ingest_filepath.blank?

          full_ingest_file_path = File.join(Curator.config.ingest_source_directory, ingest_filepath)

          raise ActiveStorage::Error, "Could not find file at #{full_ingest_file_path}" if !File.file?(full_ingest_file_path)

          File.open(full_ingest_file_path, 'rb')
        end

        def fedora_io(fedora_content_location)
          return if fedora_content_location.blank?

          http = Down::Http.new do |client|
            # adding conditionals on fedora_content_location.match?(/FOXML/)
            # causes errors, so just use basic auth on everything
            client.timeout(connect: 120, write: 240, read: 540)
                  .basic_auth(user: Curator.config.fedora_credentials[:fedora_username],
                              pass: Curator.config.fedora_credentials[:fedora_password])
          end
          http.download(fedora_content_location)
        end

        def uploaded_file_io(uploaded_file)
          return if uploaded_file.blank?

          case uploaded_file
          when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
            uploaded_file
          else
            raise ActiveStorage::Error, "Unknown object class for uploaded file: #{uploaded_file.class}"
          end
        end
      end
    end
  end
end
