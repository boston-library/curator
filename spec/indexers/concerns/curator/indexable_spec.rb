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

    describe 'called directly on object' do
      it 'makes an update request to the solr_url' do
        inst_to_update = @indexable_object.clone
        inst_to_update.curator_indexable_mapper = Curator::Indexer.new
        inst_to_update.update_index
        assert_requested :post, solr_update_url,
                         body: body_for_update_request(inst_to_update)
      end
    end
  end

  describe 'background jobs' do
    before(:each) do
      ActiveJob::Base.queue_adapter = :test
    end

    describe '#queue_indexing_job' do
      it 'enqueues the IndexingJob' do
        @indexable_object.queue_indexing_job
        expect(Curator::Indexer::IndexingJob).to have_been_enqueued
      end
    end

    describe '#queue_deletion_job' do
      it 'enqueues the DeletionJob' do
        @indexable_object.queue_deletion_job
        expect(Curator::Indexer::DeletionJob).to have_been_enqueued
      end
    end
  end
end
