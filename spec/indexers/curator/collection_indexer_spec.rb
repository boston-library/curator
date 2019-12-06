# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::CollectionIndexer do
  # set exemplary mapping here, relationship not created by factory
  before(:all) do
    @collection = create(:curator_collection)
    exemplary_file_set = create(:curator_filestreams_image)
    exemplary_mapping = Curator::Mappings::ExemplaryImage.new(exemplary_object: @collection,
                                                              exemplary_file_set: exemplary_file_set)
    exemplary_mapping.save!
  end

  describe 'indexing' do
    let(:indexer) { described_class.new }
    let(:indexed) { indexer.map_record(@collection) }

    it 'sets the title fields' do
      expect(indexed['title_info_primary_tsi']).to eq [@collection.name]
      expect(
        indexed['title_info_primary_ssort']
      ).to eq [Curator::Parsers::InputParser.get_proper_title(@collection.name).last]
    end

    it 'sets the abstract field' do
      expect(indexed['abstract_tsi']).to eq [@collection.abstract]
    end

    it 'sets the physical location and institution fields' do
      pi_fields = %w(physical_location_ssim physical_location_tsim institution_name_ssi institution_name_tsi)
      pi_fields.each do |field|
        expect(indexed[field]).to eq [@collection.institution.name]
      end
      expect(indexed['institution_ark_id_ssi']).to eq [@collection.institution.ark_id]
    end

    it 'sets the exemplary image field' do
      expect(indexed['exemplary_image_ssi']).to eq [@collection.exemplary_file_set.ark_id]
    end
  end
end
