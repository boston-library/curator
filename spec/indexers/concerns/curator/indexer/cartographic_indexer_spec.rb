# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::CartographicIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::CartographicIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) { create(:curator_metastreams_descriptive) }
    let(:descriptable_object) { descriptive.descriptable }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the scale field' do
      expect(indexed['scale_tsim']).to eq descriptive.cartographic.scale
    end

    it 'sets the projection field' do
      expect(indexed['projection_tsi']).to eq [descriptive.cartographic.projection]
    end
  end
end
