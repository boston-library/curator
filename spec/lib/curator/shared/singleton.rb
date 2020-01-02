# frozen_string_literal: true

RSpec.shared_examples 'singleton' do
  subject { described_class }

  it { is_expected.to respond_to(:instance) }
  it 'expects the #initialize method to raise error' do
    expect { subject.new }.to raise_error(NoMethodError, /private method `new' called for/)
  end
end
