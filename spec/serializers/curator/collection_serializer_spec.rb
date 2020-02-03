# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'

RSpec.describe Curator::CollectionSerializer, type: :serializers do
  pending
  let(:record) { create(:curator_collection, :with_metastreams) }
  let!(:collection_count) { 3 }
  let!(:records) { create_list(:curator_collection, collection_count, :with_metastreams) }
  let!(:expected_as_json_options) do
    {

    }
  end

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end
end
