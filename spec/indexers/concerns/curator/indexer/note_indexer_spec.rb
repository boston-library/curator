# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Indexer::NoteIndexer do
  describe 'indexing' do
    let(:indexer_test_class) do
      Class.new(Curator::Indexer) do
        include Curator::Indexer::NoteIndexer
      end
    end
    let(:indexer) { indexer_test_class.new }
    let(:descriptive) { create(:curator_metastreams_descriptive) }
    let(:descriptable_object) { descriptive.digital_object }
    let(:indexed) { indexer.map_record(descriptable_object) }

    it 'sets the identifier fields' do
      descriptive.note.each do |note|
        expect(indexed["note_#{note.type}_tsim"]).to include(note.label)
      end
    end
  end
end
