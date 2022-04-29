# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::AdministrativeSerializer, type: :serializers do
  let!(:record) { create(:curator_metastreams_administrative, :for_oai_object) }

  describe 'Serialization' do
    it_behaves_like 'json_serialization', include_collections: false do
      let(:json_record) { record }
      let(:json_array) { [] }

      let(:expected_json) do
        proc do |administrative|
          Alba.serialize(administrative) do
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

            attributes :description_standard, :flagged, :harvestable, :destination_site, :oai_header_id, :hosting_status
          end
        end
      end
    end
  end
end
