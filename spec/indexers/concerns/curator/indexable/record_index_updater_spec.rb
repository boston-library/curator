# frozen_string_literal: true

require 'rails_helper'
require_relative './../indexable_shared'
RSpec.describe Curator::Indexable::RecordIndexUpdater do
  include_context 'indexable_shared'
  let(:record_index_updater) { Curator::Indexable::RecordIndexUpdater.new(institution) }
  let(:non_persisted) { build(:curator_institution) }

  describe '#mapper' do
    it 'returns the curator_indexable_mapper' do
      expect(record_index_updater.mapper.class.superclass).to eq Curator::Indexer
    end
  end

  describe '#writer' do
    it 'returns the Traject::Writer' do
      expect(record_index_updater.writer).to be_an_instance_of Traject::SolrJsonWriter
    end
  end

  describe '#should_be_in_index?' do
    it 'returns true for persisted objects' do
      expect(record_index_updater.should_be_in_index?).to be_truthy
    end

    it 'returns false for non-persisted objects' do
      expect(Curator::Indexable::RecordIndexUpdater.new(non_persisted).should_be_in_index?).to be_falsey
    end
  end

  describe '#update_index' do
    before do
      institution.curator_indexable_mapper = Curator::Indexer.new
      stub_request(:post, solr_update_url)
    end
    it 'makes an update request to the solr_url' do
      record_index_updater.update_index
      assert_requested :post, solr_update_url,
                       body: institution_update_request_body
    end
  end
end
