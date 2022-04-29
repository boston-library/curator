# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::ControlledTerms::GeographicSerializer, type: :serializers do
  let!(:geographic_count) { 3 }
  let!(:record) { create(:curator_controlled_terms_geographic) }
  let!(:record_collection) { create_list(:curator_controlled_terms_geographic, geographic_count) }

  describe 'Base Behavior' do
    it_behaves_like 'nomenclature_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_json) do
        proc do |geographic|
          Alba.serialize(geographic) do
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

            root_key :geographic, :geographics

            attributes :label, :id_from_auth, :authority_code, :bounding_box, :area_type, :coordinates
          end
        end
      end
    end
  end
end
