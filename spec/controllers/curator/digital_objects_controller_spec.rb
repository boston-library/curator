# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::DigitalObjectsController, type: :controller do
  let!(:resource) { create(:curator_digital_object) }
  let!(:valid_attributes) do
    attributes = attributes_for(:curator_digital_object).except(:administrative, :descriptive, :workflow)
    relation_attributes = load_json_fixture('digital_object')
    parent = create(:curator_collection, institution: create(:curator_institution, :with_location))

    attributes.merge!({
        admin_set: { ark_id: parent.ark_id },
        is_member_of_collection: [{ ark_id: parent.ark_id }],
        metastreams: relation_attributes.dup.delete('metastreams')
      })
    end

  let(:valid_session) { {} }
  let(:base_params) { {} }
  let(:invalid_attributes) { valid_attributes.dup.update(admin_set: {}) }
  let(:resource_class) { Curator::DigitalObject }
  let(:serializer_class) { Curator::DigitalObjectSerializer }

  include_examples 'shared_formats', include_ark_context: true, skip_post: false, resource_key: 'digital_object'

  skip "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested digital_object" do
        digital_object = Curator::DigitalObject.create! valid_attributes
        put :update, params: { id: digital_object.to_param, digital_object: new_attributes }, session: valid_session
        digital_object.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the digital_object" do
        digital_object = Curator::DigitalObject.create! valid_attributes

        put :update, params: { id: digital_object.to_param, digital_object: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the digital_object" do
        digital_object = Curator::DigitalObject.create! valid_attributes

        put :update, params: { id: digital_object.to_param, digital_object: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
