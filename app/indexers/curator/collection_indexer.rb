# frozen_string_literal: true

module Curator
  class CollectionIndexer < Curator::Indexer
    include Curator::Indexer::WorkflowIndexer
    include Curator::Indexer::AdministrativeIndexer
    include Curator::Indexer::ExemplaryImageIndexer

    # TODO: add indexing for: edit_access_group_ssim
    configure do
      to_field %w(title_info_primary_tsi title_info_primary_ssi), obj_extract('name')

      to_field 'title_info_primary_ssort' do |record, accumulator|
        accumulator << Curator::Parsers::InputParser.get_proper_title(record.name).last
      end

      to_field 'abstract_tsi', obj_extract('abstract')
      to_field %w(physical_location_ssim physical_location_tim institution_name_ssi institution_name_ti),
               obj_extract('institution', 'name')
      to_field 'institution_ark_id_ssi', obj_extract('institution', 'ark_id')

      to_field %w(genre_basic_ssim genre_basic_tim) do |record, accumulator|
        accumulator << 'Collections'
        # iterate over child DigitalObject and get genre values
        genre_labels = []

        Curator.metastreams.descriptive_class.with_desc_terms.where(digital_object_id: record.admin_set_object_ids).find_each do |desc|
          genre_labels += desc.genres.basic_genres.collect(&:label)
        end

        genre_labels.each do |genre_label|
          next if genre_label == 'Serial Publications'

          accumulator << genre_label if accumulator.exclude?(genre_label)
        end
      end
    end
  end
end
