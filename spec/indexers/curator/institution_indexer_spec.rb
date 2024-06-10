# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::InstitutionIndexer do
  describe 'indexing' do
    let(:indexer) { described_class.new }
    let(:institution) { create(:curator_institution) }
    let(:indexed) { indexer.map_record(institution) }

    it 'sets the title fields' do
      %w(title_info_primary_tsi title_info_primary_ssi).each do |field|
        expect(indexed[field]).to eq [institution.name]
      end
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

    it 'sets the institution ark_id field' do
      expect(indexed['institution_ark_id_ssi']).to eq [institution.ark_id]
    end
  end
end
