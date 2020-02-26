# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ErrorSerializer, type: :serializers do
  let(:error_count) { 5 }
  let(:error) { Curator::Exceptions::ServerError.new }
  let(:error_collection) { Array.new(error_count) { Curator::Exceptions::ServerError.new } }

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { error }
      let(:json_array) { error_collection }
      let(:expected_as_json_options) { { root: true } }
    end
  end
end
