# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::InstitutionIndexer do
  describe 'indexing' do
    let(:indexer) { described_class.new }
    let(:institution) { create(:curator_institution) }
    let(:indexed) { indexer.map_record(institution) }

    it 'sets the title fields' do
      expect(indexed['title_info_primary_tsi']).to eq [institution.name]
      expect(
        indexed['title_info_primary_ssort']
      ).to eq [Curator::Parsers::InputParser.get_proper_title(institution.name).last]
    end

    it 'sets the physical location field' do
      expect(indexed['physical_location_ssim']).to eq [institution.name]
    end

    it 'sets the abstract field' do
      expect(indexed['abstract_tsi']).to eq [institution.abstract]
    end

    it 'sets the uri field' do
      expect(indexed['institution_url_ss']).to eq [institution.url]
    end

    it 'sets the genre fields' do
      %w(genre_basic_ssim genre_basic_tsim).each do |field|
        expect(indexed[field]).to eq [institution.class.name.demodulize]
      end
    end
  end
end
