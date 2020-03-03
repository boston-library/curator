# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::InstitutionsController, type: :controller do
  let(:valid_session) { {} }

  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let!(:serializer_class) { Curator::InstitutionSerializer }
  let!(:resource) { create(:curator_institution, :with_location) }
  let!(:resource_key) { 'institution' }
  let!(:base_params) { {} }

  include_examples 'shared_formats', include_ark_context: true

  skip 'POST #create' do
    context "with valid params" do
      it "creates a new Curator::Institution" do
        expect {
          post :create, params: { institution: valid_attributes }, session: valid_session
        }.to change(Curator::Institution, :count).by(1)
      end

      it "renders a JSON response with the new institution" do
        post :create, params: { institution: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(institution_url(Curator::Institution.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new institution" do
        post :create, params: { institution: invalid_attributes }, session: valid_session
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

      it "updates the requested institution" do
        institution = Curator::Institution.create! valid_attributes
        put :update, params: { id: institution.to_param, institution: new_attributes }, session: valid_session
        institution.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the institution" do
        institution = Curator::Institution.create! valid_attributes

        put :update, params: { id: institution.to_param, institution: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    skip "with invalid params" do
      it "renders a JSON response with errors for the institution" do
        institution = Curator::Institution.create! valid_attributes

        put :update, params: { id: institution.to_param, institution: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
