# frozen_string_literal: true

# has_many_attached not currently used in any model, keep in case needed in the future
module Curator
  class Indexer < Traject::Indexer
    module AttachmentIndexer
      extend ActiveSupport::Concern

      ATTACHMENT_FIELDS = %i(byte_size content_type checksum).freeze
      HAS_ONE_ATTACHMENT_TYPES = %i(audio_access audio_master document_access document_master
                                    ebook_access_epub ebook_access_mobi ebook_access_daisy
                                    image_access_800 image_georectified_master image_master image_negative_master
                                    image_service image_thumbnail_300 metadata_foxml metadata_ia metadata_ia_scan
                                    metadata_marc_xml metadata_mods metadata_oai text_coordinates_access
                                    text_coordinates_master text_plain video_access video_master).freeze
      # HAS_MANY_ATTACHMENT_TYPES = %i().freeze

      included do
        configure do
          each_record do |record, context|
            attachments = {}
            HAS_ONE_ATTACHMENT_TYPES.each do |attachment_type|
              next unless record.respond_to?(attachment_type) && record.public_send(attachment_type).attached?

              attachment_hash = {}
              attachment_hash[:filename] = record.public_send(attachment_type).filename.to_s
              ATTACHMENT_FIELDS.each do |blob_attr|
                attachment_hash[blob_attr] = record.public_send(attachment_type).public_send(blob_attr)
              end
              attachments[attachment_type] = attachment_hash
            end

            # HAS_MANY_ATTACHMENT_TYPES.each do |attachment_type|
            #   next unless record.respond_to?(attachment_type) && record.send(attachment_type).attached?

            #   blobs = record.public_send(attachment_type).blobs
            #   next if blobs.blank?

            #   attachments_arr = blobs.inject([]) do |ba, blob|
            #     attachment_hash = {}
            #     attachment_hash[:filename] = blob.filename.to_s
            #     ATTACHMENT_FIELDS.each do |blob_attr|
            #       attachment_hash[blob_attr] = blob.public_send(blob_attr)
            #     end
            #     ba << attachment_hash
            #   end
            #   attachments[attachment_type] = attachments_arr
            # end
            context.output_hash['attachments_ss'] = attachments.present? ? attachments.to_json : nil
          end
        end
      end
    end
  end
end
