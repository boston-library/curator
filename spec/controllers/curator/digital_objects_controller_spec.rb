# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::DigitalObjectsController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # DigitalObject. As you add validations to DigitalObject, be sure to
  # adjust the attributes here as well.

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # DigitalObjectsController. Be sure to keep this updated too.
  let!(:valid_session) { {} }
  let!(:valid_attributes) { load_json_fixture('digital_object') }
  let!(:invalid_attributes) { valid_attributes.dup.update(admin_set: nil) }
  let!(:resource_class) { Curator::DigitalObject }
  let!(:serializer_class) { Curator::DigitalObjectSerializer }
  let!(:resource) { create(:curator_digital_object) }
  let!(:base_params) { {} }


  include_examples 'shared_formats', include_ark_context: true, resource_key: 'digital_object'

  skip "POST #create" do
    context "with valid params" do
      it "creates a new Curator::DigitalObject" do
        expect {
          post :create, params: { digital_object: valid_attributes }, session: valid_session
        }.to change(Curator::DigitalObject, :count).by(1)
      end

      it "renders a JSON response with the new digital_object" do
        post :create, params: { digital_object: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(digital_object_url(Curator::DigitalObject.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new digital_object" do
        post :create, params: { digital_object: invalid_attributes }, session: valid_session
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
