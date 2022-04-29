# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'

RSpec.describe Curator::DigitalObjectSerializer, type: :serializers do
  let!(:digital_object_count) { 2 }
  let!(:desc_term_count) { 2 }
  let!(:objs) { create_list(:curator_digital_object, digital_object_count, desc_term_count: desc_term_count) }
  let!(:record) { objs.last }

  let!(:record_collection) do
    Curator.digital_object_class.where(id: objs.pluck(:id)).for_serialization
  end

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_json) do
        proc do |digital_object|
          Alba.serialize(digital_object) do
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

            root_key :digital_object, :digital_objects

            has_one :admin_set do
              attributes :ark_id
            end

            has_one :contained_by do
              attributes :ark_id
            end

            has_many :is_member_of_collection do
              attributes :ark_id
            end

            has_one :metastreams do
              has_one :administrative do
                attributes :description_standard, :harvestable, :flagged, :destination_site, :hosting_status
              end

              has_one(:descriptive, &descriptive_json_block)

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
