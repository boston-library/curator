# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/schema/conditional'
RSpec.describe Curator::Serializers::Relation, type: :lib_serializers do
  let!(:collection_relation_facet) { build_facet_inst(klass: described_class, key: :collections, serializer_klass: other_serializer_class) }
  let!(:single_relation_facet) { build_facet_inst(klass: described_class, key: :location, serializer_klass: single_serializer_class) }
  let!(:parent_record) { create(:curator_institution, :with_location, collection_count: 5) }
  let!(:serializer_options) { { adapter_key: :json } }
  let!(:other_serializer_class) do
    Class.new(Curator::Serializers::AbstractSerializer) do
      schema_as_json root: :other do
        attributes :ark_id, :name, :abstract
      end
    end
  end

  let!(:single_serializer_class) do
    Class.new(Curator::Serializers::AbstractSerializer) do
      schema_as_json root: :location do
        attributes :id_from_auth, :label
      end
    end
  end

  describe 'fail on #initialize' do
    let(:blank_class) { Class.new }
    it 'is expected to raise error for an invalid or nil serializer class' do
      expect { build_facet_inst(klass: described_class, key: :list, serializer_klass: nil) }.to raise_error(RuntimeError, /Invalid Serializer Class/)
      expect { build_facet_inst(klass: described_class, key: :list, serializer_klass: blank_class) }.to raise_error(RuntimeError, /Serializer #{blank_class} does not inherit from Curator::Serializers::AbstractSerializer!/)
    end
  end

  include_examples 'conditional_attributes' do
    let(:serializable_record) { parent_record }

    let(:key) { :collections }

    let(:if_facet) { build_facet_inst(klass: described_class, key: key, serializer_klass: other_serializer_class, options: if_proc) }
    let(:unless_facet) { build_facet_inst(klass: described_class, key: key, serializer_klass: other_serializer_class, options: unless_proc) }
    let(:combined_facet) { build_facet_inst(klass: described_class, key: key, serializer_klass: other_serializer_class, options: if_proc.merge(unless_proc)) }
  end

  describe 'serialize relationships' do
    describe 'collection' do
      subject { collection_relation_facet.serialize(parent_record, serializer_options) }
      let(:other_records) { parent_record.collections.map {|col| { attributes: col.as_json(only: [:ark_id, :name, :abstract]).symbolize_keys } } }

      it { is_expected.to be_a_kind_of(Array).and all(be_a_kind_of(Hash)).and all(have_key(:attributes)) }

      it 'expects to be serialized based on the other_serializer_class' do
        expect(subject.count).to eq(parent_record.collections.count)
        expect(subject).to match_array(other_records)
      end

      describe 'from schema' do
        subject { serialize_facet_inst(collection_relation_facet, parent_record, serializer_options) }

        it { is_expected.to be_a_kind_of(Hash).and have_key(:collections) }

        it 'expects to be serialized by the schema properly' do
          expect(subject[:collections]).to be_a_kind_of(Array).and all(have_key(:attributes))
          expect(subject[:collections].count).to eq(parent_record.collections.count)
        end
      end

      describe 'null_serializer' do
        subject { collection_relation_facet.serialize(parent_record) }

        it 'expects the null serializer to call serialize when no adapter_key is passed in' do
          expect(subject).to be_a_kind_of(Array).and be_empty
        end
      end
    end

    describe 'single' do
      subject { single_relation_facet.serialize(parent_record, serializer_options) }

      let(:location_record) { { attributes: parent_record.location.as_json(only: [:id_from_auth, :label], methods: [:id_from_auth, :label]).symbolize_keys } }

      it { is_expected.to be_a_kind_of(Hash).and have_key(:attributes) }

      it 'is expected to have been serialized based on single_serializer_class' do
        expect(subject).to match(location_record)
      end

      describe 'from schema' do
        subject { serialize_facet_inst(single_relation_facet, parent_record, serializer_options) }

        it { is_expected.to be_a_kind_of(Hash).and have_key(:location) }

        it 'expects to be serialized by the schema properly' do
          expect(subject[:location]).to be_a_kind_of(Hash).and have_key(:attributes).and match(location_record)
        end
      end

      describe 'null serializer' do
        subject { single_relation_facet.serialize(parent_record) }

        it 'expects the null serializer to call serialize when no adapter_key is passed in' do
          expect(subject).to be_a_kind_of(Hash).and be_empty
        end
      end
    end
  end
end
