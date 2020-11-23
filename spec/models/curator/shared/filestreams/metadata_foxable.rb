# frozen_string_literal: true

RSpec.shared_examples 'metadata_foxable', type: :model do
  describe '#metadata_foxml' do
    it { is_expected.to have_one_attached(:metadata_foxml) }

    it 'is expected to be a kind of active storage attachment' do
      expect(subject.metadata_foxml).to be_an_instance_of(ActiveStorage::Attached::One)
    end
  end
end
