# frozen_string_literal: true

RSpec.shared_examples_for 'mintable', type: :model do
  describe '#ark_id' do
    it { is_expected.to validate_presence_of :ark_id }
    it { is_expected.to validate_uniqueness_of :ark_id }
  end
end
