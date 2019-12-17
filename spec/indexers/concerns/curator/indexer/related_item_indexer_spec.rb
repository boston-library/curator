# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::RelatedItemIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::RelatedItemIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) do
      descriptive_ms = create(:curator_metastreams_descriptive)
      create_list(:curator_mappings_host_collection, 2).each do |hcol|
        descriptive_ms.host_collections << hcol
      end
      descriptive_ms
    end
    let(:descriptable_object) { descriptive.descriptable }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the related_item_host fields' do
      %w(related_item_host_tim related_item_host_ssim).each do |field|
        expect(indexed[field]).to eq descriptive.host_collections.map(&:name)
      end
    end

    it 'sets the related_item_series fields' do
      %w(related_item_series_ti related_item_series_ssi).each do |field|
        expect(indexed[field]).to eq [descriptive.series]
      end
    end

    it 'sets the related_item_subseries fields' do
      %w(related_item_subseries_ti related_item_subseries_ssi).each do |field|
        expect(indexed[field]).to eq [descriptive.subseries]
      end
    end

    it 'sets the related_item_subsubseries fields' do
      %w(related_item_subsubseries_ti related_item_subsubseries_ssi).each do |field|
        expect(indexed[field]).to eq [descriptive.subsubseries]
      end
    end

    it 'sets the related_item_constituent field' do
      expect(indexed['related_item_constituent_tsim']).to eq [descriptive.related.constituent]
    end

    it 'sets the related_item_isreferencedby field' do
      expect(indexed['related_item_isreferencedby_ssm']).to eq descriptive.related.referenced_by_url
    end
  end
end
