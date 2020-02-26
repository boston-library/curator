# frozen_string_literal: true

require 'rails_helper'

RSpec.shared_examples 'serializable_error' do
  specify { expect(described_const).to be_truthy.and be <= Curator::Exceptions::SerializableError }

  let!(:serializable_error_instance) { described_const.new }

  describe 'inherited instance methods' do
    subject { serializable_error_instance }

    it { is_expected.to respond_to(:title, :detail, :status, :source, :to_h, :to_s, :as_json) }
    it { is_expected.to delegate_method(:to_s).to(:to_h) }
  end
end

RSpec.shared_examples 'model_error' do
  specify { expect(described_const).to be_truthy.and be <= Curator::Exceptions::ModelError }

  let!(:model_error_instance) { described_const.new }

  describe 'inherited instance methods' do
    subject { described_const.new }

    it { is_expected.to respond_to(:model_errors) }
  end
end
