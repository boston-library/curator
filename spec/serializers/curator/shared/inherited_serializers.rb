# frozen_string_literal: true

RSpec.shared_examples_for 'curator_serializer', type: :serializers do
  describe 'Curator::CuratorSerializer' do
    let!(:adapter_key) { :json }
    let!(:base_attribute_keys) { serializer_adapter_schema_attributes(Curator::CuratorSerializer, adapter_key).map(&:to_s) }
    let!(:described_class_attribute_keys) { serializer_adapter_schema_attributes(described_class, adapter_key).map(&:to_s) }
    let!(:described_class_instance) { described_class.new(record, adapter_key: adapter_key) }

    it 'is expected to be a kind of Curator::CuratorSerializer'do
      expect(described_class_instance).to be_a_kind_of(Curator::CuratorSerializer)
    end

    it 'expects the base attribute keys to be in the described class attribute keys' do
      expect(described_class_attribute_keys).to include(*base_attribute_keys)
    end

    describe 'inherited serializer attributes' do
      subject { described_class_instance.serializable_hash }

      it 'is expected to have base attributes in serializable_hash' do
        expect(subject.keys).to include(*base_attribute_keys)
      end
    end
  end
end

RSpec.shared_examples_for 'access_condition_serializer', type: :serializers do
  describe 'Curator::ControlledTerms::AccessConditionSerializer' do
    let!(:adapter_key) { :json }
    let!(:base_attribute_keys) { serializer_adapter_schema_attributes(Curator::ControlledTerms::AccessConditionSerializer, adapter_key).map(&:to_s) }
    let!(:described_class_attribute_keys) { serializer_adapter_schema_attributes(described_class, adapter_key).map(&:to_s) }
    let!(:described_class_instance) { described_class.new(record, adapter_key: adapter_key) }

    it 'is expected to be a kind of Curator::CuratorSerializer'do
      expect(described_class_instance).to be_a_kind_of(Curator::ControlledTerms::AccessConditionSerializer)
    end

    it 'expects the base attribute keys to be in the described class attriubute keys' do
      expect(described_class_attribute_keys).to include(*base_attribute_keys)
    end

    describe 'inherited serializer attributes' do
      subject { described_class_instance.serializable_hash }

      let(:attribute_keys) { base_attribute_keys }

      it 'is expected to have base attributes in serializable_hash' do
        expect(subject.keys).to include(*attribute_keys)
      end
    end
  end
end

RSpec.shared_examples_for 'nomenclature_serializer', type: :serializers do
  describe 'Curator::ControlledTerms::NomenclatureSerializer' do
    let(:adapter_key) { :json }
    let(:base_attribute_keys) { serializer_adapter_schema_attributes(Curator::ControlledTerms::NomenclatureSerializer, adapter_key) }
    let(:described_class_attribute_keys) { serializer_adapter_schema_attributes(described_class, adapter_key) }
    let(:described_class_instance) { described_class.new(record, adapter_key: adapter_key) }

    it 'is expected to be a kind of Curator::ControlledTerms::NomenclatureSerializer'do
      expect(described_class_instance).to be_a_kind_of(Curator::ControlledTerms::NomenclatureSerializer)
    end

    it 'expects the base attribute keys to be in the described class attribute keys' do
      expect(described_class_attribute_keys).to include(*base_attribute_keys)
    end

    describe 'inherited serializer attributes' do
      subject { described_class_instance.serializable_hash }

      let(:attribute_keys) { base_attribute_keys }

      it 'is expected to have base attributes in serializable_hash' do
        expect(subject.keys).to include(*base_attribute_keys)
      end
    end
  end
end

RSpec.shared_examples_for 'file_set_serializer', type: :serializers do
  it_behaves_like 'curator_serializer'
  describe 'Curator::Filestreams::FileSetSerializer' do
    let(:adapter_key) { :json }
    let(:base_attribute_keys) { serializer_adapter_schema_attributes(Curator::Filestreams::FileSetSerializer, adapter_key) }
    let(:described_class_attribute_keys) { serializer_adapter_schema_attributes(described_class, adapter_key) }
    let(:described_class_instance) { described_class.new(record, adapter_key: adapter_key) }

    it 'is expected to be a kind of Curator::CuratorSerializer'do
      expect(described_class_instance).to be_a_kind_of(Curator::Filestreams::FileSetSerializer)
    end

    it 'expects the base attribute keys to be in the described class attriubute keys' do
      expect(described_class_attribute_keys).to include(*base_attribute_keys)
    end

    describe 'inherited serializer attributes' do
      subject { base_attribute_keys }

      let(:serialized_hash) { described_class_instance.serializable_hash }
      let(:attribute_keys) { serialized_hash.keys }

      it 'is expected to have base attributes in serializable_hash' do
        expect(subject).to include(*attribute_keys)
      end
    end
  end
end
