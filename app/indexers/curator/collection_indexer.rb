# frozen_string_literal: true

module Curator
  class CollectionIndexer < Curator::Indexer
    include Curator::Indexer::WorkflowIndexer
    include Curator::Indexer::AdministrativeIndexer
    include Curator::Indexer::ExemplaryImageIndexer

    # TODO: add indexing for: edit_access_group_ssim
    configure do
      to_field 'title_info_primary_tsi', obj_extract('name')
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
        # TODO: find a better way? (query Solr?), this is probably pretty expensive
        Curator.digital_object_class.with_metastreams.where(admin_set_id: record.id).find_each do |obj|
          obj.descriptive.genres.basic_genres.find_each do |genre|
            accumulator << genre.label unless accumulator.include?(genre.label)
          end
        end
      end
    end
  end
end
