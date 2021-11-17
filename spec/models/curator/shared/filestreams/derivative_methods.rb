# frozen_string_literal: true

RSpec.shared_examples 'derivative_methods' do
  describe '#required_derivatives_complete?' do
    it 'expects :DEFAULT_REQUIRED_DERIVATIVES to be a defined constant' do
      expect(described_class).to be_const_defined(:DEFAULT_REQUIRED_DERIVATIVES)
    end

    it 'is expected to respond_to #required_derivatives_complete?' do
      expect(subject).to respond_to(:required_derivatives_complete?).with(1).argument
      expect(subject).to_not be_required_derivatives_complete
    end

    it 'is expected to respond_to #avi_payload' do
      expect(subject).to respond_to(:avi_payload)
    end

    it 'is expected to respond_to #derivative_source_changed?' do
      expect(subject).to respond_to(:derivative_source_changed?)
      expect(subject).to_not be_derivative_source_changed
    end
  end
end
