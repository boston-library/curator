# frozen_string_literal: true

RSpec.shared_examples 'derivative_methods' do
  describe '#required_derivatives_complete?' do
    it 'expects :DEFAULT_REQUIRED_DERIVATIVES to be a defined constant' do
      expect(described_class).to be_const_defined(:DEFAULT_REQUIRED_DERIVATIVES)
    end

    it 'expects to respond_to #required_derivatives_complete?' do
      expect(subject).to respond_to(:required_derivatives_complete?).with(1).argument
      expect(subject.required_derivatives_complete?).to be_falsey
    end
  end

  describe '#derivatives_payload' do
    it { is_expected.to respond_to(:derivatives_payload) }

    describe 'expected results' do
      let!(:expected_payload) { subject.derivatives_payload }
      let!(:expected_hash_keys) { %i(file_set_class ark_id derivatives) }

      it 'is expected to return a hash' do
        expect(expected_payload).to be_a_kind_of(Hash)
        expect(expected_payload).to include(*expected_hash_keys)
        expect(expected_payload[:derivatives]).to be_a_kind_of(Array)
      end
    end
  end
end
