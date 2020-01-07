# frozen_string_literal: true

RSpec.shared_examples 'dsl', type: :lib_serializers do
  subject { described_serializer_class }

  it { is_expected.to respond_to(:cache_enabled=, :schema_as_json, :schema_as_xml) }

  let(:cache_enabled_orig) { subject.cache_enabled? }
  it 'is expected to enable and disable the cache on the class level' do
    expect { subject.cache_enabled = !cache_enabled_orig }.to change(subject, :cache_enabled?).from(cache_enabled_orig).to(!cache_enabled_orig)
  end

  it 'is expected to always have the null adapter schema key set' do
    expect(subject.send(:_adapter_schemas).keys).to include(:null)
    expect(subject.send(:_schema_for_adapter, :null)).to be_an_instance_of(Curator::Serializers::NullAdapter)
  end

  describe 'inherited schemas' do
    let(:inherited_class) { Class.new(described_serializer_class) }

    it 'expects the same schema adapters to be mapped to the serializer' do
      expect(subject.send(:_adapter_schemas).keys).to match_array(inherited_class.send(:_adapter_schemas).keys)
      expect(inherited_class.send(:_adapter_schemas).values).to all(be_a_kind_of(Curator::Serializers::AdapterBase))
    end
  end
end
