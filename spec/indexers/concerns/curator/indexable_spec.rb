# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexable do
  before(:all) { @institution = create(:curator_institution) }

  describe 'class methods' do
    describe '#index_with' do
      it 'accepts a block and yields arguments' do
        expect { |b| described_class.index_with(&b) }.
            to yield_successive_args(Curator::Indexable::ThreadSettings)
      end
    end

    describe 'auto_callbacks?' do
      it 'returns true if indexing auto callbacks are enabled' do
        expect(described_class.auto_callbacks?(@institution)).to eq true
      end
    end
  end

  describe 'included class attributes' do
    describe 'curator_indexable_mapper' do
      it 'returns as expected' do
        expect(@institution.curator_indexable_mapper.class.superclass).to eq Curator::Indexer
      end
    end

    describe 'curator_indexable_mapper' do
      it 'returns as expected' do
        expect(@institution.curator_indexable_auto_callbacks).to be_truthy
      end
    end
  end

  describe '#update_index' do
    let(:institution) { create(:curator_institution) }
    let(:solr_update_url) { "#{ENV['SOLR_URL']}/update/json?softCommit=true" }

    describe 'called on save' do
      before do
        institution.curator_indexable_mapper = Curator::Indexer.new
        stub_request(:post, solr_update_url)
      end
      it 'makes a request to the solr_url' do
        institution.update_index
        assert_requested :post, solr_update_url,
                         body: [{ 'id' => [institution.ark_id],
                                  'system_create_dtsi' => [institution.created_at.as_json],
                                  'system_modified_dtsi' => [institution.updated_at.as_json],
                                  'curator_model_ssi' => [institution.class.name],
                                  'curator_model_suffix_ssi' => [institution.class.name.demodulize] }].to_json
      end
    end

    describe 'called on delete' do
      it 'makes a delete request to the solr_url' do
        institution.destroy!
        assert_requested :post, solr_update_url,
                         body: { 'delete' => institution.ark_id }.to_json
      end
    end
  end
end
