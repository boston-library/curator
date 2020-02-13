# frozen_string_literal: true

module Curator
  class FileSetIndexer < Curator::Indexer
    include Curator::Indexer::WorkflowIndexer
    include Curator::Indexer::AttachmentIndexer

    # NOTE: fields below were previously set in Bplmodels::File#to_solr, but no longer needed(?):
    #   label_ssi filename_ssi page_num_label_type_ssi mime_type_tesim(set on Blob instead)
    #   is_image_of_ssim is_audio_of_ssim is_document_of_ssim is_ereader_of_ssim is_volume_of_ssim
    #   is_following_image_of_ssim is_following_audio_of_ssim is_following_document_of_ssim is_following_ereader_of_ssim
    #   is_preceding_image_of_ssim is_preceding_audio_of_ssim is_preceding_document_of_ssim is_preceding_ereader_of_ssim

    # NOTE: fields below were previously set in Bplmodels::File#to_solr, but have been updated:
    #   derivative_processsed_ssi->processing_state_ssi is_file_of_ssim->is_file_set_of_ssim
    #   hand_side_ssi->page_hand_side_ssi has_djvu_json_ssi->has_wordcoords_json_bsi
    #   object_profile_ssm->attachments_ss

    # TODO: add indexing for:
    #         edit_access_group_ssim
    configure do
      to_field 'is_file_set_of_ssim', obj_extract('file_set_of', 'ark_id')
      to_field 'is_exemplary_image_of_ssim' do |rec, acc|
        acc.concat rec.exemplary_image_of.pluck('ark_id')
      end
      to_field 'filename_base_ssi', obj_extract('file_name_base')
      to_field 'position_isi', obj_extract('position')
      to_field('page_type_ssi') { |rec, acc| acc << rec.pagination['page_type'] }
      to_field('page_num_label_ssi') { |rec, acc| acc << rec.pagination['page_label'] }
      to_field('page_hand_side_ssi') { |rec, acc| acc << rec.pagination['hand_side'] }
      to_field 'georeferenced_bsi' do |rec, acc|
        acc << true if rec.respond_to?(:image_georectified_master_attachment) && rec.image_georectified_master_attachment.present?
      end
      to_field 'has_wordcoords_json_bsi' do |rec, acc|
        acc << true if rec.respond_to?(:text_coordinates_access_attachment) && rec.text_coordinates_access_attachment.present?
      end
      each_record do |record, context|
        next unless record.respond_to?(:text_plain_attachment) && record.text_plain_attachment.present?

        context.output_hash['has_ocr_text_bsi'] = true
        record.text_plain_attachment.download do |file|
          context.output_hash['ocr_tsiv'] = Curator::Parsers::InputParser.utf8_encode(file)
        end
      end
    end
  end
end
