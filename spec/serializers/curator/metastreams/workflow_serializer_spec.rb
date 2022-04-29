# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::WorkflowSerializer, type: :serializers do
  let!(:record) { create(:curator_metastreams_workflow) }

  describe 'Serialization' do
    it_behaves_like 'json_serialization', include_collections: false do
      let(:json_record) { record }
      let(:expected_json) do
        proc do |workflow|
          Alba.serialize(workflow, root: :workflow) do
            include include Module.new do
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

            attributes :publishing_state, :processing_state, :ingest_origin
          end
        end
      end
    end
  end
end
