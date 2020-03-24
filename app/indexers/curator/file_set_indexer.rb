# frozen_string_literal: true

module Curator
  class FileSetIndexer < Curator::Indexer
    include Curator::Indexer::WorkflowIndexer
    include Curator::Indexer::AttachmentIndexer

    # TODO: add indexing for: edit_access_group_ssim
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
