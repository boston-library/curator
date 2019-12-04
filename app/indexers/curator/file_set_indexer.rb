# frozen_string_literal: true

module Curator
  class FileSetIndexer < Curator::Indexer
    include Curator::Indexer::WorkflowIndexer

    # NOTE: fields below were previously set in Bplmodels::File#to_solr, but no longer needed(?):
    #   label_ssi filename_ssi page_num_label_type_ssi mime_type_tesim(set on Blob instead)
    #   is_image_of_ssim is_audio_of_ssim is_document_of_ssim is_ereader_of_ssim is_volume_of_ssim
    #   is_following_image_of_ssim is_following_audio_of_ssim is_following_document_of_ssim is_following_ereader_of_ssim
    #   is_preceding_image_of_ssim is_preceding_audio_of_ssim is_preceding_document_of_ssim is_preceding_ereader_of_ssim

    # NOTE: fields below were previously set in Bplmodels::File#to_solr, but have been updated:
    #   derivative_processsed_ssi->processing_state_ssi is_file_of_ssim->is_file_set_of_ssim
    #   hand_side_ssi->page_hand_side_ssi

    # TODO: add indexing for:
    #         ocr_tsiv has_ocr_text_bsi edit_access_group_ssim
    #         has_djvu_json_ssi georeferenced_bsi
    configure do
      to_field 'is_file_set_of_ssim', obj_extract('file_set_of', 'ark_id')
      to_field 'is_exemplary_image_of_ssim' do |record, accumulator|
        if record.respond_to?(:exemplary_image_objects)
          record.exemplary_image_objects.each do |exemplary_object|
            accumulator << exemplary_object.ark_id
          end
        end
        if record.respond_to?(:exemplary_image_collections)
          record.exemplary_image_collections.each do |exemplary_col|
            accumulator << exemplary_col.ark_id
          end
        end
      end
      to_field 'filename_base_ssi', obj_extract('file_name_base')
      to_field 'position_isi', obj_extract('position')
      to_field('page_type_ssi') { |rec, acc| acc << rec.pagination['page_type'] }
      to_field('page_num_label_ssi') { |rec, acc| acc << rec.pagination['page_label'] }
      to_field('page_hand_side_ssi') { |rec, acc| acc << rec.pagination['hand_side'] }
    end
  end
end
