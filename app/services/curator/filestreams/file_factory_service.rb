# frozen_string_literal: true

module Curator
  class Filestreams::FileFactoryService < Services::Base
    include Services::FactoryService

    # TODO: figure out a way to call attach without invoking ActiveStorage::AnalyzeJob
    # We can invoke NullAnalyzer by setting below in config/application.rb:
    #   config.active_storage.analyzers = []
    #   config.active_storage.previewers = []
    # However, even if we do above, ActiveStorage will compute byte_size, content_type, and checksum anyway
    def call
      file_set_ark_id = @json_attrs.dig('filestream_of', 'ark_id')
      begin
        ActiveStorage::Attachment.transaction do
          file_set = Curator::Filestreams::FileSet.find_by(ark_id: file_set_ark_id)
          raise "FileSet #{file_set_ark_id} not found!" unless file_set
          attachment_type = attachment_for_ds(@json_attrs.fetch('file_type', ''))
          filename = @json_attrs.fetch('file_name', nil)
          content_type = @json_attrs.fetch('content_type', nil)
          metadata = @json_attrs.fetch('metadata', {})

          # TODO: we'll probably need some better logic for this
          file_to_attach = File.open(metadata.fetch('ingest_filepath', nil))
          file_set.send(attachment_type).attach(io: file_to_attach,
                                                filename: filename,
                                                content_type: content_type,
                                                metadata: metadata)

          file = file_set.send(attachment_type).blob
          if file
            file.created_at = @created if @created
            file.save!
          end
          return file
        end
      rescue StandardError => e
        puts e.to_s
      end
    end

    private

    # format legacy datastream names as ActiveStorage Attachement types
    def attachment_for_ds(datastream_name)
      return nil if datastream_name.blank?
      attachment_type = datastream_name.underscore
      attachment_type.insert(-4, '_') if datastream_name.match? /(300|800|marcxml)\z/
      attachment_type
    end
  end
end
