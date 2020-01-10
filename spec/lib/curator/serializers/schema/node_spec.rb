# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/schema/conditional'

RSpec.describe Curator::Serializers::Node, type: :lib_serializers do
  subject { build_facet_inst(klass: described_class, key: :my_key) { 'I require a block!' } }

  let!(:descriptive) { create(:curator_metastreams_descriptive, genre_count: 5) }
  let!(:delegated_schema_methods) { %i(root attribute attributes node has_one has_many belongs_to) }

  it { is_expected.to respond_to(:schema, :serialize, :include_value?, :read_for_serialization) }
  it { is_expected.to respond_to(*delegated_schema_methods) }

  it 'is expected to raise error without a block' do
    expect { build_facet_inst(klass: described_class, key: :some_key) }.to raise_error(RuntimeError, 'Node requires a Block!')
  end

  it 'expects certain methods to be delegated to schema' do
    delegated_schema_methods.each do |schema_method|
      expect(subject).to delegate_method(schema_method).to(:schema)
    end
  end

  include_examples 'conditional_attributes' do
    let(:serializable_record) { descriptive }
    let(:key) { :title }
    let(:if_facet) do
      build_facet_inst(klass: described_class, key: key, options: { target: :key }.merge(if_proc)) do
        attribute :primary do |target, _serializer_params|
          target.as_json
        end
      end
    end

    let(:unless_facet) do
      build_facet_inst(klass: described_class, key: key, options: { target: :key }.merge(unless_proc)) do
        attribute :primary do |target, _serializer_params|
          target.as_json
        end
      end
    end

    let(:combined_facet) do
      build_facet_inst(klass: described_class, key: key, options: { target: :key }.merge(if_proc).merge(unless_proc)) do
        attribute :primary do |target, _serializer_params|
          target.as_json
        end
      end
    end
  end

  describe 'complex node' do
    subject { complex_node.serialize(descriptive, { adapter_key: :json }) }

    let!(:serialized_facet_keys) { %i(attributes nodes relations) }
    let!(:node_attributes) { %i(abstract access_restrictions digital_origin frequency issuance origin_event extent physical_location_department physical_location_shelf_locator place_of_publication publisher rights series subseries subsubseries toc toc_url) }
    let!(:identifier_json) { descriptive.identifier.as_json.map { |a| { attributes: a.reject { |_k, v| v.blank? }.symbolize_keys } } }
    let!(:relation_json) do
      descriptive.genres.map do |genre|
        {
          attributes: genre.as_json(only: [:basic, :label, :id_from_auth],
                                    methods: [:basic, :label, :id_from_auth]).
                            reject { |_k, v| v.blank? }.
                            symbolize_keys
        }
      end
    end

    let!(:complex_node) do
      build_facet_inst(klass: described_class, key: :descriptive) do
        attributes :abstract, :access_restrictions, :digital_origin, :frequency, :issuance, :origin_event, :extent, :physical_location_department, :physical_location_shelf_locator, :place_of_publication, :publisher, :rights, :series, :subseries, :subsubseries, :toc, :toc_url

        has_many :genres, serializer: Class.new(Curator::Serializers::AbstractSerializer) { schema_as_json(root: :genre) { attributes :basic, :label, :id_from_auth } }

        node :identifier, target: :key do
          attributes :label, :type, :invalid
        end
      end
    end
    it 'should serialize the node with the correct facet keys' do
      serialized_facet_keys.each do |facet_key|
        expect(subject).to have_key(facet_key)
        expect(subject[facet_key]).to be_a_kind_of(Hash).or be_a_kind_of(Array)
      end
    end

    it 'should have the correct attributes serialized' do
      node_attributes.each do |node_attr|
        expect(subject[:attributes]).to have_key(node_attr)
        expect(subject[:attributes][node_attr]).to eq(descriptive.public_send(node_attr))
      end
    end

    it 'should have a sub node that serializes as array' do
      expect(subject[:nodes]).to have_key(:identifier)
      expect(subject[:nodes][:identifier]).to be_a_kind_of(Array).and all(have_key(:attributes))
      expect(subject[:nodes][:identifier]).to match_array(identifier_json)
    end

    it 'should have serialized relationships' do
      expect(subject[:relations]).to have_key(:genres)
      expect(subject[:relations][:genres]).to be_a_kind_of(Array).and all(have_key(:attributes))
      expect(subject[:relations][:genres]).to match_array(relation_json)
    end
  end
end
