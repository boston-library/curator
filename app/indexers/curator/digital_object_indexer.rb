# frozen_string_literal: true

module Curator
  class DigitalObjectIndexer < Curator::Indexer
    include Curator::Indexer::DescriptiveIndexer
    include Curator::Indexer::WorkflowIndexer
    include Curator::Indexer::AdministrativeIndexer
    include Curator::Indexer::ExemplaryImageIndexer

    # TODO: add indexing for: contained_by_ark_id_ssi edit_access_group_ssim
    configure do
      to_field 'admin_set_name_ssi', obj_extract('admin_set', 'name')
      to_field 'admin_set_ark_id_ssi', obj_extract('admin_set', 'ark_id')
      to_field %w(institution_name_ssi institution_name_ti), obj_extract('institution', 'name')
      to_field 'institution_ark_id_ssi', obj_extract('institution', 'ark_id')
      to_field %w(collection_name_ssim collection_name_tim) do |record, accumulator|
        accumulator.concat record.is_member_of_collection.pluck(:name)
      end

      to_field 'collection_ark_id_ssim' do |record, accumulator|
        accumulator.concat record.is_member_of_collection.pluck(:ark_id)
      end

      to_field 'contained_by_ssi', obj_extract('contained_by', 'ark_id')
      to_field('filenames_ssim') { |rec, acc| acc.concat rec.file_set_members.distinct.pluck(:file_name_base) }

      each_record do |record, context|
        serializer = Curator::DigitalObjectSerializer.new(record, adapter_key: :mods)
        context.output_hash['mods_xml_ss'] = Base64.strict_encode64(Zlib::Deflate.deflate(serializer.serialize))

        if record.image_file_sets.present?
          has_searchable_pages, georeferenced = false, false
          record.image_file_sets.each do |image_file_set|
            has_searchable_pages = true if image_file_set.text_plain_attachment.present?
            georeferenced = true if image_file_set.image_georectified_primary_attachment.present?
          end

          context.output_hash['has_searchable_pages_bsi'] = has_searchable_pages.presence
          context.output_hash['georeferenced_bsi'] = georeferenced.presence
        end

        next if record.text_file_sets.blank?

        text_plain_attachment = record.text_file_sets.first.text_plain_attachment

        next if text_plain_attachment.blank?

        text_plain_attachment.download do |file|
          context.output_hash['ocr_tiv'] = Curator::Parsers::InputParser.clean_text(file)
        end

        context.output_hash['has_transcription_bsi'] = true
      end
    end
  end
end
