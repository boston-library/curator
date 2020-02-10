# frozen_string_literal: true

RSpec.shared_examples_for 'curator_serializer', type: :serializers do
  describe 'Curator::CuratorSerializer' do
    let(:adapter_key) { :json }
    let(:base_attribute_keys) { serializer_adapter_schema_attributes(Curator::CuratorSerializer, adapter_key, :attributes) }
    let(:described_class_attribute_keys) { serializer_adapter_schema_attributes(described_class, adapter_key, :attributes) }
    let(:described_class_instance) { described_class.new(record, adapter_key) }

    it 'is expected to be a kind of Curator::CuratorSerializer'do
      expect(described_class_instance).to be_a_kind_of(Curator::CuratorSerializer)
    end

    it 'expects the base attribute keys to be in the described class attriubute keys' do
      expect(described_class_attribute_keys).to include(*base_attribute_keys)
    end

    describe 'inherited serializer attributes' do
      subject { described_class_instance.serializable_hash }

      let(:root_key) { fetch_transformed_root_key(described_class_instance) }

      it 'is expected to have base attributes in serializable_hash' do
        expect(subject).to have_key(root_key)
        expect(subject[root_key].keys).to include(*base_attribute_keys)
      end
    end
  end
end

RSpec.shared_examples_for 'nomenclature_serializer', type: :serializers do |has_id_from_auth: true|
  describe 'Curator::ControlledTerms::NomenclatureSerializer' do
    let(:adapter_key) { :json }
    let(:base_attribute_keys) { serializer_adapter_schema_attributes(Curator::ControlledTerms::NomenclatureSerializer, adapter_key, :attributes) }
    let(:attribute_keys_proc) { -> (use_id_from_auth) { use_id_from_auth ? base_attribute_keys : base_attribute_keys.reject { |a| a == 'id_from_auth' } } }
    let(:described_class_attribute_keys) { serializer_adapter_schema_attributes(described_class, adapter_key, :attributes) }
    let(:described_class_instance) { described_class.new(record, adapter_key) }

    it 'is expected to be a kind of Curator::CuratorSerializer'do
      expect(described_class_instance).to be_a_kind_of(Curator::ControlledTerms::NomenclatureSerializer)
    end

    it 'expects the base attribute keys to be in the described class attriubute keys' do
      expect(described_class_attribute_keys).to include(*base_attribute_keys)
    end

    describe 'inherited serializer attributes' do
      subject { described_class_instance.serializable_hash }

      let(:root_key) { fetch_transformed_root_key(described_class_instance) }
      let(:attribute_keys) { attribute_keys_proc.call(has_id_from_auth) }

      it 'is expected to have base attributes in serializable_hash' do
        expect(subject).to have_key(root_key)
        expect(subject[root_key].keys).to include(*attribute_keys)
      end
    end
  end
end

RSpec.shared_examples_for 'file_set_serializer', type: :serializers do
  it_behaves_like 'curator_serializer'
  describe 'Curator::Filestreams::FileSetSerializer' do
    let(:adapter_key) { :json }
    let(:base_attribute_keys) { serializer_adapter_schema_attributes(Curator::Filestreams::FileSetSerializer, adapter_key, :attributes) }
    let(:described_class_attribute_keys) { serializer_adapter_schema_attributes(described_class, adapter_key, :attributes) }
    let(:described_class_instance) { described_class.new(record, adapter_key) }

    it 'is expected to be a kind of Curator::CuratorSerializer'do
      expect(described_class_instance).to be_a_kind_of(Curator::Filestreams::FileSetSerializer)
    end

    it 'expects the base attribute keys to be in the described class attriubute keys' do
      expect(described_class_attribute_keys).to include(*base_attribute_keys)
    end

    describe 'inherited serializer attributes' do
      subject { described_class_instance.serializable_hash }

      let(:root_key) { fetch_transformed_root_key(described_class_instance) }
      let(:attribute_keys) { base_attribute_keys }

      it 'is expected to have base attributes in serializable_hash' do
        expect(subject).to have_key(root_key)
        expect(subject[root_key].keys).to include(*attribute_keys)
      end
    end
  end
end
