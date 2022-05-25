# frozen_string_literal: true

RSpec.shared_examples 'dsl', type: :lib_serializers do
  subject { described_serializer_class }

  let(:adapter_schemas) { subject.send(:_adapter_schemas) }

  it 'is expected to always have the null adapter schema key set' do
    expect(adapter_schemas.keys).to include(:null)
    expect(subject.send(:_schema_builder_for_adapter, :null)).to be_an_instance_of(Curator::Serializers::NullAdapter)
  end

  describe 'inherited schemas' do
    let(:inherited_class) do
      Class.new(described_serializer_class) do
        build_schema_as_json do
          attributes :a_different_attribute
        end
      end
    end

    let(:inherited_class_adapter_schemas) { inherited_class.send(:_adapter_schemas) }
    let(:schema_attributes_proc) { ->(val) { schema_attribute_keys(val.schema_builder_class) if val.schema_builder_class } }
    let(:schema_attributes) { adapter_schemas.values.flat_map(&schema_attributes_proc).compact }
    let(:inherited_schema_attributes) { inherited_class_adapter_schemas.values.flat_map(&schema_attributes_proc).compact }

    it 'expects the inherted class to have more attributes mapped to the adapters schema' do
      expect(schema_attributes).not_to match_array(inherited_schema_attributes)
      expect(schema_attributes.count).to be < inherited_schema_attributes.count
    end
  end
end
