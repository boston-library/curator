# frozen_string_literal: true

# has_many_attached not currently used in any model, keep in case needed in the future
module Curator
  class Indexer < Traject::Indexer
    module AttachmentIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            attachments = {}
            has_one_attachment_types = %i(audio_access audio_master document_access document_master
                                          ebook_access_epub ebook_access_mobi ebook_access_daisy
                                          image_access_800 image_georectified_master image_master image_negative_master
                                          image_service image_thumbnail_300 metadata_foxml metadata_ia metadata_ia_scan
                                          metadata_marc_xml metadata_mods metadata_oai text_coordinates_access
                                          text_coordinates_master text_plain video_access video_master).freeze
            has_many_attachment_types = []
            attachment_fields = %i(byte_size content_type checksum).freeze

            has_one_attachment_types.each do |attachment_type|
              next unless record.respond_to?(attachment_type)

              blob = record.send("#{attachment_type}_attachment")&.blob
              next if blob.blank?

              blob_hash = {}
              blob_hash[:filename] = blob.filename.to_s
              attachment_fields.each do |blob_attribute|
                blob_hash[blob_attribute] = blob.public_send(blob_attribute)
              end
              attachments[attachment_type] = blob_hash
            end

            has_many_attachment_types.each do |attachment_type|
              next unless record.respond_to?(attachment_type)

              blobs = record.public_send("#{attachment_type}_attachments").map(&:blob)
              next if blobs.blank?

              blobs_arr = blobs.inject([]) do |ba, blob|
                blob_hash = {}
                blob_hash[:filename] = blob.filename.to_s
                attachment_fields.each do |blob_attribute|
                  blob_hash[blob_attribute] = blob.public_send(blob_attribute)
                end
                ba << blob_hash
              end
              attachments[attachment_type] = blobs_arr
            end
            context.output_hash['attachments_ss'] = attachments.present? ? attachments.to_json : nil
          end
        end
      end
    end
  end
end
