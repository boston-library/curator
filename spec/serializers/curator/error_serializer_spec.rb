# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ErrorSerializer, type: :serializers do
  let!(:error_count) { 5 }
  let!(:error) { Curator::Exceptions::ServerError.new }
  let!(:error_collection) { Array.new(error_count) { Curator::Exceptions::ServerError.new } }

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { error }
      let(:json_array) { error_collection }
      let(:expected_json) do
        proc do |error|
          Alba.serialize(error) do
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

            root_key :error, :errors

            attributes :status, :title, :detail, :source
          end
        end
      end
    end
  end
end
