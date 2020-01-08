# frozen_string_literal: true

module Curator
  class Indexer < Traject::Indexer
    module AttachmentIndexer
      extend ActiveSupport::Concern
      included do
        configure do
          each_record do |record, context|
            attachments = {}
            attachment_types = %i(audio_access audio_master document_access document_master ebook_access
                                  image_access_800 image_georectified_master image_master image_negative_master
                                  image_service image_thumbnail_300 metadata_foxml metadata_ia metadata_ia_scan
                                  metadata_marc_xml metadata_mods metadata_oai text_coordinates_access
                                  text_coordinates_master text_plain video_access video_master)
            attachment_types.each do |attachment_type|
              next unless record.respond_to?(attachment_type)

              blob = record.send("#{attachment_type}_attachment")&.blob
              next unless blob

              blob_hash = { filename: blob.filename.to_s }
              %i(byte_size content_type checksum).each do |blob_attribute|
                blob_hash[blob_attribute] = blob.send(blob_attribute)
              end
              attachments[attachment_type] = blob_hash
            end
            context.output_hash['attachments_ss'] = attachments.to_json
          end
        end
      end
    end
  end
end
