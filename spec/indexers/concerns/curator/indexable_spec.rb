# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexable do
  let(:institution) { create(:curator_institution) }

  describe 'class methods' do
    describe '#index_with' do
      it 'accepts a block and yields arguments' do
        expect { |b| described_class.index_with(&b) }.
            to yield_successive_args(Curator::Indexable::ThreadSettings)
      end
    end

    describe 'auto_callbacks?' do
      it 'returns true if indexing auto callbacks are enabled' do
        expect(described_class.auto_callbacks?(institution)).to eq true
      end
    end
  end

  describe 'included class attributes' do
    describe 'curator_indexable_mapper' do
      it 'returns as expected' do
        expect(institution.curator_indexable_mapper).to be_truthy
        expect(institution.curator_indexable_mapper.class.superclass).to eq Curator::Indexer
      end
    end

    describe 'curator_indexable_mapper' do
      it 'returns as expected' do
        expect(institution.curator_indexable_auto_callbacks).to be_truthy
      end
    end
  end
end
