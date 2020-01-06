# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::Node, type: :lib_serializers do

  subject { build_facet_inst(klass: described_class, key: :my_key) { 'I require a block!' } }

  let!(:delegated_schema_methods) { %i(root attribute attributes node has_one has_many belongs_to) }

  it { is_expected.to respond_to(:schema, :serialize, :include_value?, :read_for_serialization) }
  it { is_expected.to respond_to(*delegated_schema_methods) }

  it 'is expected to raise error without a block' do
    expect { build_facet_inst(klass: described_class, key: :some_key) }.to raise_error(RuntimeError, 'Node requires a Block!')
  end

  it 'expects certain methods to be delegated to schema' do
    delegated_schema_methods.each do |schema_method|
      expect(subject).to delegate_method(schema_method).to(:schema)
    end
  end
end
