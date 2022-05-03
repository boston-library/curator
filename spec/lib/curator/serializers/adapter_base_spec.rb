# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::AdapterBase, type: :lib_serializers do
  subject { described_class.new(base_builder_class: Class.new) }

  it { is_expected.to respond_to(:serializable_hash, :serialize, :base_builder_class, :schema_builder_class) }

  it 'is expected to raise errors for the base class methods' do
    expect { subject.serializable_hash }.to raise_error(Curator::Exceptions::CuratorError, 'Not Implemented')
    expect { subject.serialize }.to raise_error(Curator::Exceptions::CuratorError, 'Not Implemented')
  end
end
