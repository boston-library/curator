# frozen_string_literal: true

RSpec.shared_examples 'reindex_descriptable', type: :model do
  describe '#reindex_descriptable_objects' do
    it 'runs the reindex_descriptable_objects callback' do
      expect(test_term).to receive(:reindex_descriptable_objects)
      test_term.save
    end
  end
end
