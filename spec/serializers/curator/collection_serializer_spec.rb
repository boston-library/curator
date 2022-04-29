# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'

RSpec.describe Curator::CollectionSerializer, type: :serializers do
  let!(:collection_count) { 2 }

  let!(:record_collection) { create_list(:curator_collection, collection_count) }
  let!(:record) { record_collection.last }

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_json) do
        proc do |collection|
          Alba.serialize(collection) do
            include Module.new do
              private

              # @returns [Hash] Overrides Alba::Resource#converter
              def converter
                super >> proc { |hash| deep_format_and_compact(hash) }
              end

              # @return [Hash] - Removes blank values and formats time ActiveSupport::TimeWithZone values to iso8601
              def deep_format_and_compact(hash)
                hash.reduce({}) do |ret, (key, value)|
                  new_val = case value
                            when Hash
                              deep_format_and_compact(value)
                            when Array
                              value.map { |v| v.is_a?(Hash) ? deep_format_and_compact(v) : v }
                            when ActiveSupport::TimeWithZone
                              value.iso8601
                            else
                              value
                            end
                  ret[key] = new_val
                  ret
                end.compact_blank
              end
            end

            root_key :collection, :collections

            attributes :ark_id, :created_at, :updated_at, :abstract, :name

            has_one :institution do
              attributes :ark_id
            end

            has_one :metastreams do
              has_one :administrative do
                attributes :description_standard, :harvestable, :flagged, :destination_site, :hosting_status
              end

              has_one :workflow do
                attributes :publishing_state, :processing_state, :ingest_origin
              end
            end
          end
        end
      end
    end
  end
end
