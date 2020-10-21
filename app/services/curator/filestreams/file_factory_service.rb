# # frozen_string_literal: true
#
# module Curator
#   class Filestreams::FileFactoryService < Services::Base
#     include Services::FactoryService
#
#     # TODO: figure out a way to call attach without invoking ActiveStorage::AnalyzeJob
#     # We can invoke NullAnalyzer by setting below in config/application.rb:
#     #   config.active_storage.analyzers = []
#     #   config.active_storage.previewers = []
#     # However, even if we do above, ActiveStorage will compute byte_size, content_type, and checksum anyway
#     def call
#       file_set_ark_id = @json_attrs.dig('filestream_of', 'ark_id')
#
#       filename = @json_attrs.fetch('file_name', nil)
#       content_type = @json_attrs.fetch('content_type', nil)
#       byte_size = @json_attrs.fetch('byte_size', nil)
#       checksum_md5 = @json_attrs.fetch('checksum_md5', nil)
#       metadata = @json_attrs.fetch('metadata', {})
#       io = @json_attrs.fetch('io', {})
#       file_set_type = @json_attrs.dig('filestream_of', 'file_set_type')
#
#       with_transaction do
#         attachment_type = attachment_for_ds(@json_attrs.fetch('file_type', ''))
#
#         raise ArgumentError, "Invalid attachment type #{attachment_type}" if attachment_type.blank?
#
#         file_set = Curator.filestreams.public_send("#{file_set_type}_class").public_send("with_attached_#{attachment_type}").find_by!(ark_id: file_set_ark_id)
#         file_to_attach = io_for_file(@json_attrs.fetch('fedora_content_location', nil), metadata['ingest_filepath'])
#
#         file_set.public_send(attachment_type).attach(io: file_to_attach,
#                                                      filename: filename,
#                                                      content_type: content_type,
#                                                      metadata: metadata)
#
#         @record = file_set.public_send(attachment_type).blob if file_set.public_send(attachment_type)&.attached? && file_set.public_send(attachment_type)&.blob
#
#         raise ActiveRecord::Error, "Could not get blob for #{attachment_type} for FileSet ark_id=#{file_set.ark_id}" if @record.blank?
#
#         @record.lock!
#         check_file_fixity(@record, byte_size, checksum_md5)
#         @record.created_at = @created if @created
#         @record.save!
#       end
#       return @success, @result
#     end
#
#
#   end
# end
