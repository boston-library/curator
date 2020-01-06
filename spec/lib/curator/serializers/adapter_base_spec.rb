# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::AdapterBase, type: :lib_serializers do
  subject { described_class.new({ root: :my_root }) { 'I require a block!' } }

  let!(:delegated_schema_methods) { %i(root attribute attributes node meta link has_one has_many belongs_to) }

  it { is_expected.to respond_to(:schema, :serializable_hash, :render) }
  it { is_expected.to respond_to(*delegated_schema_methods) }

  it 'expects certain methods to be delegated to the schema' do
    delegated_schema_methods.each do |schema_method|
      expect(subject).to delegate_method(schema_method).to(:schema)
    end
  end

  it 'is expected to raise errors for the base class methods' do
    expect { subject.serializable_hash }.to raise_error(RuntimeError, 'Not Implemented')
    expect { subject.render }.to raise_error(RuntimeError, 'Not Implemented')
  end
end
