# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::PublicationIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::PublicationIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) { create(:curator_metastreams_descriptive) }
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the volume field' do
      expect(indexed['volume_tsi']).to eq [descriptive.publication.volume]
    end

    it 'sets the edition_name field' do
      expect(indexed['edition_name_tsi']).to eq [descriptive.publication.edition_name]
    end

    it 'sets the edition_number field' do
      expect(indexed['edition_number_tsi']).to eq [descriptive.publication.edition_number]
    end

    it 'sets the issue_number field' do
      expect(indexed['issue_number_tsi']).to eq [descriptive.publication.issue_number]
    end
  end
end
