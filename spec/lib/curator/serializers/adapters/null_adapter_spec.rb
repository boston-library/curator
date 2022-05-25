# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::NullAdapter, type: :lib_serializers do
  subject { described_class.new }

  let!(:digital_object) { build(:curator_digital_object) }
  let!(:arbitrary_class) do
    Class.new do
      def initialize(*)
        @attrs = {}
      end
    end
  end

  it 'is expected to have a limited schema' do
    expect(subject.schema_builder_class).to be_an_instance_of(NilClass)
  end

  it 'expects #serializable_hash to return an empty hash depending on what is passed in' do
    expect(subject.serializable_hash).to be_a_kind_of(Hash).and be_empty
    expect(subject.serializable_hash(nil)).to be_a_kind_of(Hash).and be_empty
    expect(subject.serializable_hash([digital_object])).to be_a_kind_of(Array).and be_empty
    expect(subject.serializable_hash([arbitrary_class.new])).to be_a_kind_of(Array).and be_empty
  end

  it 'expects #serialize to to return empty hash as a json string depending on what is passed in' do
    expect(subject.serialize).to be_a_kind_of(String).and eq '{}'
    expect(subject.serialize(nil)).to be_a_kind_of(String).and eq '{}'
    expect(subject.serialize([digital_object])).to be_a_kind_of(String).and eq '[]'
    expect(subject.serialize([arbitrary_class.new])).to be_a_kind_of(String).and eq '[]'
  end
end
