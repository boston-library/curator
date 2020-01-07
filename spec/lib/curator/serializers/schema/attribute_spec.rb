# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/schema/conditional'

RSpec.describe Curator::Serializers::Attribute, type: :lib_serializers do
  subject { build_facet_inst(klass: described_class, key: :id) }

  let!(:fields) { %i(ark_id created_at updated_at) }
  let!(:digital_object) { create(:curator_digital_object) }

  # TODO: move conditional specs into shared example
  it { is_expected.to be_an_instance_of(described_class) }

  it 'is expected to have the method set as the key' do
    expect(subject.method).to eq(subject.key)
  end

  it 'is expected to serialize the serializable_record properly' do
    expect(subject.serialize(digital_object)).to eql(digital_object.id)
  end

  include_examples 'conditional_attributes' do
    let(:serializable_record) { digital_object }

    let(:key) { :id }
    let(:method) { key }
    let(:if_facet) { build_facet_inst(klass: described_class, key: key, method: method, options: if_proc) }
    let(:unless_facet) { build_facet_inst(klass: described_class, key: key, method: method, options: unless_proc) }
    let(:combined_facet) { build_facet_inst(klass: described_class, key: key, method: method, options: if_proc.merge(unless_proc)) }
  end

  describe 'serializing attributes for objects' do
    let(:digital_object_json) { object_as_json(digital_object, { only: fields }) }
    let(:arbitrary_proc) { ->(key) { ->(record, serializer_params) { "#{record.public_send(key)} #{serializer_params[:arbitrary_value]}" } } }
    let(:arbitrary_params) { { arbitrary_value: 'Attribute' } }

    describe 'key based serializing' do
      subject { build_facet_inst_list(*fields, klass: described_class) }

      let(:serialized_attributes) { serialize_facet_inst_collection(*subject, record: digital_object) }

      it 'is expected to serialize base attributes' do
        expect(serialized_attributes).to eq(digital_object_json)
      end
    end

    describe 'method based serializing' do
      subject { build_facet_inst_list(*fields, klass: described_class, method: arbitrary_proc) }

      let(:serialized_proc_attributes) { serialize_facet_inst_collection(*subject, record: digital_object, options: arbitrary_params) }
      let(:digital_object_json_proc) { digital_object_json.each { |k, v| digital_object_json[k] = "#{v} #{arbitrary_params[:arbitrary_value]}" } }

      it 'expects #method of an attribute to be a kind of Proc' do
        expect(subject.map(&:method)).to all(be_a_kind_of(Proc))
      end

      it 'is expected to serialize proc_attributes' do
        expect(serialized_proc_attributes).to eq(digital_object_json_proc)
      end
    end
  end
end
