# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::CollectionIndexer do
  describe 'indexing' do
    let(:collection) { create(:curator_collection) }
    let(:indexer) { described_class.new }
    let(:indexed) { indexer.map_record(collection) }

    it 'sets the title fields' do
      expect(indexed['title_info_primary_tsi']).to eq [collection.name]
      expect(
        indexed['title_info_primary_ssort']
      ).to eq [Curator::Parsers::InputParser.get_proper_title(collection.name).last]
    end

    it 'sets the abstract field' do
      expect(indexed['abstract_tsi']).to eq [collection.abstract]
    end

    it 'sets the physical location and institution fields' do
      pi_fields = %w(physical_location_ssim physical_location_tim institution_name_ssi institution_name_ti)
      pi_fields.each do |field|
        expect(indexed[field]).to eq [collection.institution.name]
      end
      expect(indexed['institution_ark_id_ssi']).to eq [collection.institution.ark_id]
    end

    it 'sets the genre fields' do
      %w(genre_basic_ssim genre_basic_tim).each do |field|
        expect(indexed[field]).to eq ['Collections']
      end
    end
  end
end
