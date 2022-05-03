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
      let(:expected_json_serializer_class) do
        serializer_test_class do
          root_key :error, :errors

          attributes :status, :title, :detail, :source
        end
      end
      let(:expected_json) do
        lambda do |error|
          expected_json_serializer_class.new(error).serialize
        end
      end
    end
  end
end
