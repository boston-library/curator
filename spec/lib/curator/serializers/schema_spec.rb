# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/schema/included'

RSpec.describe Curator::Serializers::Schema, type: :lib_serializers do
  describe 'class functionality' do
    subject { described_class }

    it { is_expected.to be_const_defined(:ROOT_KEY_TRANSFORM_MAPPING) }
    it { is_expected.to be_const_defined(:Facet) }

    it 'expects :ROOT_KEY_TRANSFORM_MAPPING to have keys' do
      expect(subject.const_get(:ROOT_KEY_TRANSFORM_MAPPING).keys).to match_array(%i(camel dash underscore default))
    end
  end

  describe 'Facet Struct subclass' do
    subject { described_class.const_get(:Facet) }

    let!(:invalid_type) { :foo }
    let!(:valid_facet) { subject.new(type: :links, schema_attribute: Curator::Serializers::Link.new(key: :my_custom_link)) }

    it 'is expected to raise error if the type attribute is invalid' do
      expect { subject.new(type: invalid_type) }.to raise_error(RuntimeError, "Unknown Facet Type #{invalid_type}")
    end

    it 'is expected to be immutable' do
      expect { valid_facet.type = :my_type }.to raise_error(FrozenError, /can't modify frozen Curator::Serializers::Schema::Facet/)
    end
  end

  describe 'instance functionality' do
    subject { described_class.new(root: :my_object) }

    let!(:schema_facets) { %i(attribute attributes link meta node relation has_one has_many belongs_to) }

    it { is_expected.to respond_to(:root, :facets, :options) }
    it { is_expected.to respond_to(*schema_facets) }
    it { is_expected.to respond_to(:is_collection?, :facet_groups, :serialize, :serialize_each) }

    describe 'schema configuration' do
      it 'is expected to store attribute facets' do
        expect { subject.attributes(:id, :ark_id) }.to change { subject.facets.count }.by(2)
        expect { subject.attribute(:custom) { |record| record.present? } }.to change { subject.facets.count }.by(1)
        expect(subject.facets).to include(an_instance_of(Curator::Serializers::Schema::Facet))
        expect(subject.facet_groups).to have_key(:attributes)
        expect(subject.facet_groups[:attributes].count).to eq(3)
      end
    end
  end

  describe 'schema serialization' do
    let!(:serialized_facet_keys) { %i(attributes links meta nodes relations) }
    let!(:params) { { range: 0..20 } }
    let!(:attributes) { %i(id ark_id name) }
    let!(:custom_attr) { :abstract_trunc }
    let!(:custom_link_attr) { :https_url }
    let!(:meta_attr) { :collection_count }
    let(:node_attr) { :ark_attributes }
    let!(:collection_serializer) do
      Class.new(Curator::Serializers::AbstractSerializer) do
        schema_as_json root: :collection do
          attributes :id, :ark_id, :name, :abstract
        end
      end
    end
    let!(:location_serializer) do
      Class.new(Curator::Serializers::AbstractSerializer) do
        schema_as_json root: :location do
          attributes :id_from_auth, :label
        end
      end
    end
    let!(:schema) do
      schema = described_class.new(root: :institution)
      schema.attributes(*attributes)
      schema.attribute(custom_attr) do |record, serializer_params|
        record.abstract[serializer_params[:range]] if serializer_params[:range]
      end
      schema.link(custom_link_attr) do |record|
        uri = Addressable::URI.parse(record.url)
        uri.scheme = 'https'
        uri.to_s
      end
      schema.meta(meta_attr) { |record| record.collections.count }
      schema.node(node_attr) do
        attribute(:pid) { |record| record.ark_id }
        attribute(:model_type) { |record| record.class.to_s }
      end
      schema.has_many(:collections, serializer: collection_serializer)
      schema.belongs_to(:location, serializer: location_serializer)
      schema
    end

    include_examples 'included_fields' do
      let(:described_schema) { schema }
      let(:field_params) { { fields: %i(ark_id), adapter_key: :json } }
      let(:field_count) { field_params[:fields].count }
      let(:serializable_record) { create(:curator_institution) }
    end

    include_examples 'included_relations' do
      let(:described_schema) { schema }
      let(:included_params) { { included: %i(collections), adapter_key: :json } }
      let(:included_count) { included_params[:included].count }
      let(:serializable_record) { create(:curator_institution, :with_location, collection_count: 3) }
    end

    describe 'schema defaults' do
      subject { schema }

      let!(:key_transform_methods) { described_class.const_get(:ROOT_KEY_TRANSFORM_MAPPING) }

      it 'expects the schema to have certain defaults' do
        expect(subject).to_not be_cache_enabled
        expect(schema.cache_options).to be_a_kind_of(Hash).and be_empty
        expect(schema.key_transform_method).to eql(key_transform_methods[:default])
      end
    end

    describe 'single item serialization' do
      subject { schema.serialize(test_institution, params) }

      let!(:collection_count) { 3 }
      let!(:test_institution) { create(:curator_institution, :with_location, collection_count: collection_count) }
      it 'expects the insitution to serialize as defined in the schema' do
        serialized_facet_keys.each do |serialized_key|
          expect(subject).to be_a_kind_of(Hash).and have_key(serialized_key)
        end
      end

      it 'expects the attributes to match the values on the object' do
        attributes.each do |attribute|
          expect(subject[:attributes]).to have_key(attribute)
          expect(subject[:attributes][attribute]).to eql(test_institution.public_send(attribute))
        end
        expect(subject[:attributes]).to have_key(custom_attr)
        expect(subject[:attributes][custom_attr]).to eql(test_institution.abstract[params[:range]])
      end

      it 'expects the link attributes to have the correct values' do
        expect(subject[:links]).to have_key(custom_link_attr)
        expect(subject[:links][custom_link_attr]).to match(/#{test_institution.url[4..-1]}/)
      end

      it 'expects the meta attributes to have the correct values' do
        expect(subject[:meta]).to have_key(meta_attr)
        expect(subject[:meta][meta_attr]).to eql(test_institution.collections.count)
      end

      it 'expects the node attributes to have the correct values' do
        expect(subject[:nodes]).to have_key(node_attr)
        expect(subject[:nodes][node_attr]).to be_a_kind_of(Hash).and have_key(:attributes)
        expect(subject[:nodes][node_attr][:attributes]).to include(:pid => test_institution.ark_id, model_type: test_institution.class.to_s)
      end
    end

    describe 'multi item serialization' do
      subject { schema.serialize(institution_list, params) }

      let!(:institution_count) { 2 }
      let!(:collection_count) { 2 }
      let!(:institution_list) { create_list(:curator_institution, institution_count, :with_location, collection_count: collection_count) }

      it 'expects the collection of institutions to serialize into array' do
        expect(subject).to be_a_kind_of(Array)
        serialized_facet_keys.each do |facet_key|
          expect(subject).to all(be_a_kind_of(Hash)).and all(have_key(facet_key))
        end
      end

      it 'expects the attributes to match the institution' do
        institution_list.each do |test_institution|
          expect(subject).to include(hash_including({ attributes:
             hash_including(test_institution.as_json(only: attributes).symbolize_keys) }))
          expect(subject).to include(hash_including({ attributes:
             hash_including(custom_attr => test_institution.abstract[params[:range]]) }))
          expect(subject).to include(hash_including({ links:
            hash_including(custom_link_attr => a_string_matching(/#{test_institution.url[4..-1]}/)) }))
          expect(subject).to include(hash_including({ meta:
            hash_including(meta_attr => test_institution.collections.count) }))
        end
      end
    end
  end
end
