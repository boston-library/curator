# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::DescriptiveSerializer, type: :serializers do
  let!(:desc_term_count) { 2 }
  let!(:record) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_count) }

  describe 'Serialization' do
    it_behaves_like 'json_serialization', include_collections: false do
      let(:json_record) { record }
      let(:expected_json) do
        proc do |descriptive|
          Alba.serialize(descriptive, root_key: :descriptive) do
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

            descriptive_json_block.call
          end
        end
      end
    end
  end
end
