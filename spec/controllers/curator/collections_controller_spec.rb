# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::CollectionsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # Collection. As you add validations to Collection, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:valid_session) { {} }

  let!(:serializer_class) { Curator::CollectionSerializer }
  let!(:resource) { create(:curator_collection, :with_metastreams) }
  let!(:resource_key) { 'collection' }
  let!(:base_params) { {} }

  include_examples 'shared_formats', include_ark_context: true

  skip "POST #create" do
    context "with valid params" do
      it "creates a new Collection" do
        expect {
          post :create, params: { collection: valid_attributes }, session: valid_session
        }.to change(Curator::Collection, :count).by(1)
      end

      it "renders a JSON response with the new collection" do
        post :create, params: { collection: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(collection_url(Curator::Collection.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new collection" do
        post :create, params: { collection: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end

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
