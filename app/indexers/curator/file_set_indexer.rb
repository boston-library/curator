# frozen_string_literal: true

module Curator
  class FileSetIndexer < Curator::Indexer
    include Curator::Indexer::WorkflowIndexer
    include Curator::Indexer::AttachmentIndexer

    # TODO: add indexing for: edit_access_group_ssim
    configure do
      to_field 'is_file_set_of_ssim' do |rec, acc|
        acc.concat rec.file_set_members_of.pluck('ark_id')
      end
      to_field 'is_exemplary_image_of_ssim' do |rec, acc|
        acc.concat rec.exemplary_image_of.pluck('ark_id')
      end
      to_field 'filename_base_ssi', obj_extract('file_name_base')
      to_field 'position_isi', obj_extract('position')
      to_field('page_type_ssi') { |rec, acc| acc << rec.pagination['page_type'] }
      to_field('page_num_label_ssi') { |rec, acc| acc << rec.pagination['page_label'] }
      to_field('page_hand_side_ssi') { |rec, acc| acc << rec.pagination['hand_side'] }
      to_field 'georeferenced_bsi' do |rec, acc|
        acc << true if rec.respond_to?(:image_georectified_primary_attachment) && rec.image_georectified_primary_attachment.present?
      end
      to_field 'has_wordcoords_json_bsi' do |rec, acc|
        acc << true if rec.respond_to?(:text_coordinates_access_attachment) && rec.text_coordinates_access_attachment.present?
      end

      to_field 'destination_site_ssim' do |rec, acc|
        if rec.class.name == 'Curator::Filestreams::Image'
          acc << 'newspapers' if rec.file_set_of&.administrative&.destination_site&.include?('newspapers')
        end
      end

      each_record do |record, context|
        next unless record.respond_to?(:text_plain_attachment) && record.text_plain_attachment.present?

        context.output_hash['has_ocr_text_bsi'] = true
        record.text_plain_attachment.download do |file|
          context.output_hash['ocr_tsiv'] = Curator::Parsers::InputParser.clean_text(file)
        end
      end
    end
  end
end
