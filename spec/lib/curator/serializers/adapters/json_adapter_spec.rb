# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::JSONAdapter, type: :lib_serializers do
  let!(:record) { create(:curator_institution, :with_location, collection_count: 4) }
  let!(:options_with_root) do
    {
      root: :institution
    }
  end

  let!(:record_hash_match) do
    {
      'id' => record.id,
      'created_at' => record.created_at.utc.iso8601,
      'updated_at' => record.updated_at.utc.iso8601,
      'name' => record.name,
      'abstract' => record.abstract,
      'ark_attributes' => {
        'namespace' => record.ark_id.split(':')[0],
        'noid' => record.ark_id.split(':')[1],
        'model_type' => record.class.to_s
      },
      'arks' => {
        'collection_arks' => {
          'collection_ark_ids' => record.collections.pluck(:ark_id)
        }
      },
      'links' => {
        'url' => record.url,
        'ark_url' => "http://localhost:3001/#{record.ark_id}",
        'collection_ark_urls' => record.collections.pluck(:ark_id).map { |ark_id| "http://localhost:3001/#{ark_id}" }
      },
      'meta' => {
        'collection_count' => record.collections.count,
        'abstract_character_count' => record.abstract.length
      }
    }
  end

  let(:schema_block) do
    proc do
      attributes :id, :created_at, :updated_at, :name, :abstract

      node :ark_attributes do
        attribute(:namespace) { |record| record.ark_id.split(':').first }
        attribute(:noid) { |record| record.ark_id.split(':').last }
        attribute(:model_type) { |record| record.class.to_s }
      end

      link :url
      link(:ark_url) { |record| "http://localhost:3001/#{record.ark_id}" }

      meta(:collection_count) { |record| record.collections.count }
      meta(:abstract_character_count) { |record| record.abstract.length }

      node :arks do
        node :collection_arks do
          attribute(:collection_ark_ids) { |record| record.collections.pluck(:ark_id) }
        end
      end

      link(:collection_ark_urls) { |record| record.collections.pluck(:ark_id).map { |ark_id| "http://localhost:3001/#{ark_id}" } }
    end
  end

  let!(:json_adapter_with_root) { described_class.new(options_with_root, &schema_block) }

  let!(:json_adapter_no_root) { described_class.new({}, &schema_block) }

  describe '#serializable_hash' do
    describe 'with root' do
      subject { json_adapter_with_root.serializable_hash(record) }

      it { is_expected.to have_key('institution') }

      it 'should serialize to a hash for a JSON REST API spec' do
        expect(subject).to match('institution' => a_hash_including(record_hash_match))
      end
    end

    describe 'without_root' do
      subject { json_adapter_no_root.serializable_hash(record) }

      it { is_expected.not_to have_key('institution') }

      it 'should serialize to a hash for a JSON REST API spec' do
        expect(subject).to match(a_hash_including(record_hash_match))
      end
    end
  end

  describe '#render' do
    describe 'with_root' do
      subject { json_adapter_with_root.render(record) }

      it { is_expected.to be_a_kind_of(String) }

      it 'is expected to be parsed as json' do
        expect(Oj.load(subject)).to be_a_kind_of(Hash).and have_key('institution')
        expect(Oj.load(subject)).to match('institution' => a_hash_including(record_hash_match))
      end
    end

    describe 'without_root' do
      subject { json_adapter_no_root.render(record) }

      it { is_expected.to be_a_kind_of(String) }

      it 'is expected to be parsed as json' do
        expect(Oj.load(subject)).to be_a_kind_of(Hash)
        expect(Oj.load(subject)).to match(a_hash_including(record_hash_match))
      end
    end
  end
end
