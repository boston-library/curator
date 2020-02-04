# frozen_string_literal: true

RSpec.shared_examples 'for_serialization', type: :model do
  # Requires query stub in block when including
  describe '#for_serialization scope' do
    subject { described_class }

    it { is_expected.to respond_to(:for_serialization) }

    it 'expects the the scope as sql to match :expected_sql' do
      expect(subject.for_serialization.to_sql).to match(expected_sql)
    end
  end
end
