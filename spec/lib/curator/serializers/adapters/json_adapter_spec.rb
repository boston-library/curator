# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::JSONAdapter, type: :lib_serializers do
  let!(:institution) { create(:curator_institution, :with_location, collection_count: 4) }
  let!(:institutions) { create_list(:curator_institution, 3, collection_count: 1) }

  let!(:record_hash) do
    proc do |record|
      {
        :id => record.id,
        :created_at => record.created_at&.iso8601,
        :updated_at => record.updated_at&.iso8601,
        :name => record.name,
        :abstract => record.abstract,
        :collection_ark_ids => record.collections.pluck(:ark_id)
      }.stringify_keys
    end
  end

  let(:schema_block) do
    proc do
      root_key :institution, :institutions
      attributes :id, :created_at, :updated_at, :name, :abstract

      attribute(:collection_ark_ids) { |record| record.collections.pluck(:ark_id) }
    end
  end

  describe 'instance' do
    subject!(:json_adapter) { described_class.new(&schema_block) }

    it { is_expected.to respond_to(:base_builder_class, :schema_builder_class, :serializable_hash, :serialize) }

    describe '#serializable_hash' do
      describe 'single item' do
        subject { json_adapter.serializable_hash(institution) }

        it { is_expected.to be_a_kind_of(Hash) }

        it 'should serialize to a hash for a JSON REST API spec' do
          expect(subject).to match(a_hash_including(record_hash.call(institution)))
        end
      end

      describe 'collection' do
        subject { json_adapter.serializable_hash(institutions) }

        let(:records_array) { institutions.map { |inst| record_hash.call(inst) } }

        it 'expects the value of the institutions key to be an array' do
          expect(subject).to be_a_kind_of(Array).and all(be_a_kind_of(Hash))
        end

        it 'should serialize to a hash with an array of hashes for a JSON REST API spec' do
          expect(subject).to match_array(records_array)
        end
      end
    end

    describe '#serialize' do
      describe 'single item' do
        subject { json_adapter.serialize(institution) }

        it { is_expected.to be_a_kind_of(String) }

        it 'is expected to be parsed as json' do
          expect(Oj.load(subject)).to be_a_kind_of(Hash).and have_key('institution')
          expect(Oj.load(subject)).to match('institution' => a_hash_including(record_hash.call(institution).as_json.with_indifferent_access))
        end
      end

      describe 'collection' do
        subject { json_adapter.serialize(institutions) }

        it { is_expected.to be_a_kind_of(String) }

        let(:records_array) { institutions.map { |inst| record_hash.call(inst).as_json.with_indifferent_access } }

        it 'is expected to be parsed as json' do
          expect(Oj.load(subject)).to be_a_kind_of(Hash).and have_key('institutions')
          expect(Oj.load(subject)).to match('institutions' => records_array)
        end
      end
    end
  end
end
