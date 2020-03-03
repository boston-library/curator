# frozen_string_literal: true

module Curator
  class Filestreams::FileFactoryService < Services::Base
    include Services::FactoryService

    # TODO: figure out a way to call attach without invoking ActiveStorage::AnalyzeJob
    # We can invoke NullAnalyzer by setting below in config/application.rb:
    #   config.active_storage.analyzers = []
    #   config.active_storage.previewers = []
    # However, even if we do above, ActiveStorage will compute byte_size, content_type, and checksum anyway
    # TODO: Make the FILE_INGEST_ROOT a configurable setting
    def call
      with_transaction do
        file_set_ark_id = @json_attrs.dig('filestream_of', 'ark_id')
        attachment_type = attachment_for_ds(@json_attrs.fetch('file_type', ''))

        raise ActiveStorage::Error, "Invalid attachment type #{attachment_type}" if attachment_type.blank?

        filename = @json_attrs.fetch('file_name', nil)
        content_type = @json_attrs.fetch('content_type', nil)
        byte_size = @json_attrs.fetch('byte_size', nil)
        checksum_md5 = @json_attrs.fetch('checksum_md5', nil)
        metadata = @json_attrs.fetch('metadata', {})
        file_set_type = @json_attrs.dig('filestream_of', 'file_set_type')

        file_set = Curator.filestreams.public_send("#{file_set_type}_class").public_send("with_attached_#{attachment_type}").find_by!(ark_id: file_set_ark_id)

        file_to_attach = io_for_file(@json_attrs.fetch('fedora_content_location', nil), File.join(ENV['HOME'], metadata['ingest_filepath']))

        file_set.public_send(attachment_type).attach(io: file_to_attach,
                                                     filename: filename,
                                                     content_type: content_type,
                                                     metadata: metadata)

        @record = file_set.public_send(attachment_type).blob if file_set.public_send(attachment_type)&.attached? && file_set.public_send(attachment_type)&.blob

        raise ActiveStorage::IntegrityError, "Could not get blob for #{attachment_type} for FileSet ark_id=#{file_set.ark_id}" if @record.blank?

        @record.transaction(requires_new: true) do
          @record.lock!
          check_file_fixity(@record, byte_size, checksum_md5)
          @record.created_at = @created if @created
          @record.save!
        end
      end
    ensure
      return @success, @record
    end

    private

    # format legacy datastream names as ActiveStorage Attachement types
    def attachment_for_ds(datastream_name)
      return if datastream_name.blank?
      attachment_type = datastream_name.underscore
      attachment_type.insert(-4, '_') if datastream_name.match? /(300|800|marcxml)\z/
      attachment_type
    end

    # use fedora content URL if available, or local filepath
    def io_for_file(fedora_content_location, ingest_filepath)
      return if fedora_content_location.blank? && ingest_filepath.blank?

      if fedora_content_location
        opts = {}
        opts[:http_basic_authentication] = [ENV['FEDORA_USERNAME'], ENV['FEDORA_PASSWORD']] if fedora_content_location =~ /FOXML/
        open(fedora_content_location, opts)
      elsif ingest_filepath
        File.open(ingest_filepath, 'rb')
      end
    end

    # check ActiveStorage blob attributes against Fedora-exported data, throw error if mismatch
    # @param blob [ActiveStorage::Blob]
    # @param byte_size [Integer] size from incoming file
    # @param checksum_md5 [String] md5 checksum from incoming file
    def check_file_fixity(blob, byte_size, checksum_md5)
      return unless byte_size || checksum_md5

      if byte_size
        raise ActiveStorage::IntegrityError, "FILE SIZE MISMATCH FOR ActiveStorage::Blob: #{blob.id}" unless blob.byte_size == byte_size
      end
      if checksum_md5
        formatted_checksum = Base64.encode64(["#{checksum_md5}"].pack('H*')).chomp
        raise ActiveStorage::IntegrityError, "CHECKSUM MISMATCH FOR ActiveStorage::Blob: #{blob.id}" unless blob.checksum == formatted_checksum
      end
    end
  end
end
