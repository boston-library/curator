# frozen_string_literal: true

RSpec.shared_examples 'dsl', type: :lib_serializers do
  subject { described_serializer_class }

  let(:cache_enabled_orig) { subject.cache_enabled? }
  let(:adapter_schemas) { subject.send(:_adapter_schemas) }
  it 'is expected to enable and disable the cache on the class level' do
    expect { subject.cache_enabled = !cache_enabled_orig }.to change(subject, :cache_enabled?).from(cache_enabled_orig).to(!cache_enabled_orig)
  end

  it 'is expected to always have the null adapter schema key set' do
    expect(adapter_schemas.keys).to include(:null)
    expect(subject.send(:_schema_for_adapter, :null)).to be_an_instance_of(Curator::Serializers::NullAdapter)
  end

  describe 'inherited schemas' do
    let(:inherited_class) do
      Class.new(described_serializer_class) do
        schema_as_json do
          attributes :a_different_attribute
        end
      end
    end

    let(:inherited_class_adapter_schemas) { inherited_class.send(:_adapter_schemas) }
    let(:schema_attributes_proc) { ->(val) { schema_attribute_keys(val.schema) if val.schema } }
    let(:schema_attributes) { adapter_schemas.values.flat_map(&schema_attributes_proc).compact }
    let(:inherited_schema_attributes) { inherited_class_adapter_schemas.values.flat_map(&schema_attributes_proc).compact }

    it 'expects the inherited class to have its cache enabled setting match the parent' do
      expect(subject.cache_enabled?).to eq(inherited_class.cache_enabled?)
    end

    it 'expects the inherted class to have more attributes mapped to the adapters schema' do
      expect(schema_attributes).not_to match_array(inherited_schema_attributes)
      expect(schema_attributes.count).to be < inherited_schema_attributes.count
    end

    it 'expects the inherited class to issue warnings about overidding attributes' do
      expect do
        inherited_class.schema_as_json do
          attribute(:id) { |record| record.id.to_s }
        end
      end.to output(/id is already mapped to group attributes using falling back to previous value/).to_stderr
    end
  end
end
