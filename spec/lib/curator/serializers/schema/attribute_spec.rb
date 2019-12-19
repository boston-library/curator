# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::Attribute do
  let!(:fields){ %i(ark_id created_at updated_at) }
  let!(:digital_object) { create(:curator_digital_object) }
  subject { described_class.new(key: :id) }
  it 'is expected to behave like a serializer attribute' do
    expect(subject).to be_an_instance_of(described_class)
    expect(subject.method).to eq(subject.key)
    expect(subject.include_value?(digital_object)).to be_truthy
    expect(subject.serialize(digital_object)).to eql(digital_object.id)
  end

  describe 'serializng attributes for objects' do
    let(:object_as_json) { digital_object.as_json(only: fields) }
    let(:base_attributes) { fields.map { |field| described_class.new(key: field) } }
    let(:serialized_attributes) { base_attributes.inject({}) { |ret, attr| ret.merge(attr.key => attr.serialize(digital_object)) } }
    let(:proc_attributes) {}

    it 'is expected to serialize base attributes' do
      expect(serialized_attributes.stringify_keys).to eq(object_as_json)
    end
  end
end
