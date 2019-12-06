# frozen_string_literal: true

require 'rails_helper'
require_relative './../shared/indexable_shared'
RSpec.describe Curator::Indexable::RecordIndexUpdater do
  include_context 'indexable_shared'
  subject { described_class.new(indexable_record) }

  let(:indexable_record) { create(:curator_institution) }

  describe '#mapper' do
    it 'returns the curator_indexable_mapper' do
      expect(subject.mapper.class.superclass).to eq Curator::Indexer
    end
  end

  describe '#writer' do
    it 'returns the Traject::Writer' do
      expect(subject.writer).to be_an_instance_of Traject::SolrJsonWriter
    end
  end

  describe '#should_be_in_index?' do
    it 'returns true for persisted objects' do
      expect(subject.should_be_in_index?).to be_truthy
    end

    let(:non_persisted) { build(:curator_institution) }
    it 'returns false for non-persisted objects' do
      expect(described_class.new(non_persisted).should_be_in_index?).to be_falsey
    end
  end

  describe '#update_index' do
    before(:each) { stub_request(:post, solr_update_url) }

    it 'makes an update request to the solr_url' do
      record_to_update = indexable_record.clone
      record_to_update.curator_indexable_mapper = Curator::Indexer.new
      described_class.new(record_to_update).update_index
      assert_requested :post, solr_update_url,
                       body: body_for_update_request(record_to_update)
    end
  end
end
