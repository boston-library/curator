# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Filestreams::DocumentSerializer, type: :serializers do
  let!(:document_file_set_count) { 2 }
  let!(:record_collection) { create_list(:curator_filestreams_document, document_file_set_count) }
  let!(:record) { record_collection.last }

  describe 'Base Behavior' do
    it_behaves_like 'file_set_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }

      let(:expected_json) do
        proc do |file_set|
          Alba.serialize(file_set) do
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

            root_key :file_set, :file_sets

            attributes :ark_id, :created_at, :updated_at, :file_name_base, :position

            attribute :file_set_type do |resource|
              resource.file_set_type.demodulize.downcase
            end

            has_one :file_set_of do
              attributes :ark_id
            end

            one :pagination, if: proc { |_fs, relation| relation.present? } do
              attributes :page_label, :page_type, :hand_side
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
