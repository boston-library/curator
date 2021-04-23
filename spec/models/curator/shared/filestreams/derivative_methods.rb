# frozen_string_literal: true

RSpec.shared_examples 'derivative_methods' do
  describe '#required_derivatives_complete?' do
    it 'expects :DEFAULT_REQUIRED_DERIVATIVES to be a defined constant' do
      expect(described_class).to be_const_defined(:DEFAULT_REQUIRED_DERIVATIVES)
    end

    it 'expects to respond_to #required_derivatives_complete?' do
      expect(subject).to respond_to(:required_derivatives_complete?).with(1).argument
      expect(subject).to_not be_required_derivatives_complete
    end
  end

  describe '#ark_params' do
    it { is_expected.to respond_to(:ark_params) }

    skip 'expected results' do
      let!(:expected_payload) { subject.ark_params }
    end
  end
end
