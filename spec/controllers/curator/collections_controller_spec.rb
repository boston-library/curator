# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::CollectionsController, type: :controller do
  let!(:resource) { create(:curator_collection) }
  let!(:valid_attributes) do
    attributes = attributes_for(:curator_collection).except(:administrative, :workflow)
    relation_attributes = load_json_fixture('collection')
    parent = create(:curator_institution, :with_location)
    attributes.merge!({
      institution: { ark_id: parent.ark_id },
      metastreams: relation_attributes.dup.delete('metastreams')
    })
  end

  let(:valid_session) { {} }
  let(:base_params) { {} }
  let(:invalid_attributes) { valid_attributes.dup.update(name: nil) }
  let(:resource_class) { Curator::Collection }
  let(:serializer_class) { Curator::CollectionSerializer }


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
