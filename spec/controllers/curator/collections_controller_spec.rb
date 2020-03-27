# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::CollectionsController, type: :controller do
  let(:resource_class) { Curator::Collection }
  let(:base_params) { {} }
  let(:valid_session) { {} }
  let(:invalid_attributes) { valid_attributes.dup.update(name: nil) }
  let(:serializer_class) { Curator::CollectionSerializer }

  let!(:resource) { create(:curator_collection) }
  let!(:valid_attributes) do
    parent = create(:curator_institution, :with_location)
    collection_json = load_json_fixture('collection')
    collection_json['institution']['ark_id'] = parent.ark_id
    collection_json
  end

  include_examples 'shared_formats', include_ark_context: true, skip_post: false, resource_key: 'collection'

  skip "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested collection" do
        collection = Curator::Collection.create! valid_attributes
        put :update, params: { id: collection.to_param, collection: new_attributes }, session: valid_session
        collection.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the collection" do
        collection = Curator::Collection.create! valid_attributes

        put :update, params: { id: collection.to_param, collection: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    skip "with invalid params" do
      it "renders a JSON response with errors for the collection" do
        collection = Curator::Collection.create! valid_attributes

        put :update, params: { id: collection.to_param, collection: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
