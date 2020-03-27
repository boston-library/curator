# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/indexable_shared'
RSpec.describe Curator::Indexable do
  include_context 'indexable_shared'
  before(:all) { @indexable_object = create(:curator_institution) }

  describe 'class methods' do
    describe '#index_with' do
      it 'accepts a block and yields arguments' do
        expect { |b| described_class.index_with(&b) }.
            to yield_successive_args(Curator::Indexable::ThreadSettings)
      end
    end

    describe 'auto_callbacks?' do
      it 'returns the auto_callbacks value' do
        expect(described_class.auto_callbacks?(@indexable_object)).to be_truthy
      end
    end
  end

  describe 'included class attributes' do
    describe 'curator_indexable_mapper' do
      it 'returns as expected' do
        expect(@indexable_object.curator_indexable_mapper.class.superclass).to eq Curator::Indexer
      end
    end

    describe 'curator_indexable_mapper' do
      it 'returns as expected' do
        expect(@indexable_object.curator_indexable_auto_callbacks).to be_truthy
      end
    end
  end

  describe '#update_index' do
    before(:each) { stub_request(:post, solr_update_url) }

    describe 'called on save' do
      it 'makes an update request to the solr_url' do
        inst_to_update = @indexable_object.clone
        inst_to_update.curator_indexable_mapper = Curator::Indexer.new
        inst_to_update.save!
        assert_requested :post, solr_update_url,
                         body: body_for_update_request(inst_to_update)
      end
    end

    describe 'called on delete' do
      it 'makes a delete request to the solr_url' do
        inst_to_delete = create(:curator_institution)
        inst_to_delete.destroy!
        assert_requested :post, solr_update_url,
                         body: { 'delete' => inst_to_delete.ark_id }.to_json
      end
    end
  end

  describe '#indexer_health_check' do
    it 'does not raise an error if the indexing service is available' do
      expect do
        @indexable_object.indexer_health_check
      end.not_to raise_error(StandardError)
    end

    it 'throws a CuratorError if the indexing service is not available' do
      ClimateControl.modify SOLR_URL: 'http://127.0.0.1:9999/solr/wrong' do
        expect do
          @indexable_object.indexer_health_check
        end.to raise_error(Curator::Exceptions::CuratorError)
      end
    end
  end
end
