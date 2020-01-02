# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::Attribute do
  subject { build_facet_inst(klass: described_class, key: :id, options: conditional) }

  let!(:fields) { %i(ark_id created_at updated_at) }
  let!(:digital_object) { create(:curator_digital_object) }
  # TODO: move conditional specs into shared example
  let!(:conditional) { { if: ->(_record, serializer_params) { serializer_params[:conditional] } } }

  it { is_expected.to be_an_instance_of(described_class) }

  it 'is expected to have the method set as the key' do
    expect(subject.method).to eq(subject.key)
  end

  it 'is expects #include_value? to work properly' do
    # rubocop:disable RSpec/PredicateMatcher
    expect(subject.include_value?(digital_object, { conditional: true })).to be_truthy
    expect(subject.include_value?(digital_object, { conditional: false })).to be_falsey
    expect(subject.include_value?(digital_object, { conditional: true, fields: fields })).to be_falsey
    # rubocop:enable RSpec/PredicateMatcher
  end

  it 'is expected to serialize the value properly' do
    expect(subject.serialize(digital_object)).to eql(digital_object.id)
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
