# frozen_string_literal: true

RSpec.shared_examples_for 'digital_objectable', type: :decorators do
  specify { expect(subject).to be_an_instance_of(described_class) }

  it { is_expected.to respond_to(:digital_object).with(0).arguments }
end
