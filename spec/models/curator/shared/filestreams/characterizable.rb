# frozen_string_literal: true

RSpec.shared_examples 'characterizable', type: :model do
  describe '#characterization' do
    it { is_expected.to respond_to(:characterization) }

    it 'is expected to be a kind of active storage attachment' do
      expect(subject.characterization).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end
end
