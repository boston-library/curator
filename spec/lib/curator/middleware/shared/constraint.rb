# frozen_string_literal: true

RSpec.shared_examples 'constraint' do
  specify { expect(subject).to be_an_instance_of(described_class) }

  it { is_expected.to respond_to(:matches?).with(1).argument }
end
