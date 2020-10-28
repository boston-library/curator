# frozen_string_literal: true

module Curator
  module Filestreams
    module Attacher
      extend ActiveSupport::Concern

      included do
        include AttacherUtils
        include InstanceMethods
      end

      module InstanceMethods
        protected

        def attach_files!(file_set)
          files = @json_attrs.fetch('files', [])

          return if files.blank?

          attachments = files.group_by { |file_hash| file_hash['file_type'].underscore }

          file_set_attachments.each do |attachment_type|
            next if !attachments.key?(attachment_type)

            attach_group!(file_set, attachment_type, attachments[attachment_type])
          end
        end

        def attach_group!(file_set, attachment_type, attachments = [])
          return if attachments.blank?

          attachments.each do |attachment|
            attributes = file_attributes(attachment)

            io_hash = attachment.fetch('io', {})

            io_hash['ingest_filepath'] = attributes['metadata']['ingest_filepath'] if attributes.dig('metadata', 'ingest_filepath').present?

            attachable = build_attachable(attributes, io_hash)

            file_set.public_send(attachment_type).attach(attachable)
          end
        end

        def build_attachable(attributes, io_hash)
          return import_file_from_fedora(attributes, content_io(io_hash)) if fedora_content?(io_hash)

          {
            io: content_io(io_hash),
            filename: attributes['file_name'],
            content_type: attributes['content_type'],
            metadata: attributes['metadata']
          }
        end

        def file_attributes(attachment = {})
          attachment.slice('created_at', 'file_name', 'content_type', 'byte_size', 'checksum_md5').merge('metadata' => attachment.fetch('metadata', {}))
        end

        def fedora_content?(io = {})
          io.dig('fedora_content_location').present?
        end

        def base64_content?(io = {})
          io.dig('base64_content').present?
        end

        def ingest_content?(io = {})
          io.dig('ingest_filepath').present?
        end

        private

        # @param attachment [Hash]
        # @param io [Tempfile]
        # @returns [ActiveStorage::Blob]
        def import_file_from_fedora(attachment_attributes, io)
          blob = ActiveStorage::Blob.create_before_direct_upload!(
            filename: attachment_attributes['file_name'],
            byte_size: attachment_attributes['byte_size'],
            checksum: attachment_attributes['checksum'],
            content_type: attachment_attributes['content_type'],
            metadata: attachment_attributes['metadata']
          )
          blob.upload_without_unfurling(io)
          blob
        end

        def file_set_attachments
          file_set_class.attachment_reflections.keys
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

        # format legacy datastream names as ActiveStorage Attachement types
        def attachment_for_ds(datastream_name)
          return if datastream_name.blank?

          attachment_type = datastream_name.underscore
          attachment_type.insert(-4, '_') if datastream_name.match?(/(300|800|marcxml)\z/)
          attachment_type
        end

        # use fedora content URL if available, or local filepath, or base64 string
        def content_io(io_hash)
          return if io_hash.blank?

          return fedora_io(io_hash['fedora_content_location']) if fedora_content?(io_hash)

          return base64_io(io_hash['base64_content']) if base64_content?(io_hash)

          return file_path_io(io_hash['ingest_filepath']) if ingest_content?(io_hash)

          raise ActiveRecord::RecordNotSaved, "Unknown content for io #{type}"
        end

        # check ActiveStorage blob attributes against Fedora-exported data, throw error if mismatch
        # @param blob [ActiveStorage::Blob]
        # @param byte_size [Integer] size from incoming file
        # @param checksum_md5 [String] md5 checksum from incoming file
        def check_file_fixity(blob, byte_size, checksum_md5)
          return if byte_size.blank? && checksum_md5.blank?

          validate_byte_size!(blob, byte_size) if byte_size

          validate_checksum_md5!(blob, checksum_md5) if checksum_md5
        end

        private

        def validate_byte_size!(blob, byte_size)
          return if blob.byte_size == byte_size

          raise ActiveStorage::IntegrityError, "FILE SIZE MISMATCH FOR ActiveStorage::Blob: #{blob.id}"
        end

        def validate_checksum_md5!(blob, checksum_md5)
          formatted_checksum = Base64.encode64([checksum_md5].pack('H*')).chomp

          return if blob.checksum == formatted_checksum

          raise ActiveStorage::IntegrityError, "CHECKSUM MISMATCH FOR ActiveStorage::Blob: #{blob.id}"
        end

        def file_path_io(ingest_filepath)
          return if ingest_filepath.blank?

          File.open(ingest_filepath, 'rb')
        end

        def fedora_io(fedora_content_location)
          return if fedora_io.blank?

          http = Down::Http.new do |client|
            client.timeout(connect: 5, read: 10)
            client.basic_auth(:user => ENV['FEDORA_USERNAME'], :pass => ENV['FEDORA_PASSWORD']) if fedora_content_location.match?(/FOXML/)
          end
          http.download(fedora_content_location)
        end

        def base64_io(base64_content)
          return if base64_content.blank?

          io = StringIO.new(Base64.strict_decode64(base64_content))
          io.rewind
          io
        end
      end
    end
  end
end
