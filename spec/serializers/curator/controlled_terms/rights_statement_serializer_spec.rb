# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/inherited_serializers'
require_relative '../shared/json_serialization'

RSpec.describe Curator::ControlledTerms::RightsStatementSerializer, type: :serializers do
  let!(:right_statement_count) { 3 }
  let!(:record) { create(:curator_controlled_terms_rights_statement) }
  let!(:record_collection) { create_list(:curator_controlled_terms_rights_statement, right_statement_count) }

  describe 'Base Behavior' do
    it_behaves_like 'access_condition_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }

      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :rights_statement, :rights_statements

          attributes :label, :uri
        end
      end

      let(:expected_json) do
        lambda do |rights_statement|
          expected_json_serializer_class.new(rights_statement).serialize
        end
      end
    end
  end
end
