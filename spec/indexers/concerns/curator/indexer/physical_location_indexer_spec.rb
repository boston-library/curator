# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::PhysicalLocationIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::PhysicalLocationIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) { create(:curator_metastreams_descriptive) }
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the physical_location fields' do
      %w(physical_location_ssim physical_location_tim).each do |field|
        expect(indexed[field]).to eq [descriptive.physical_location.label]
      end
    end

    it 'sets the sub_location field' do
      expect(indexed['sub_location_tsi']).to eq [descriptive.physical_location_department]
    end

    it 'sets the shelf_locator field' do
      expect(indexed['shelf_locator_tsi']).to eq [descriptive.physical_location_shelf_locator]
    end
  end
end
