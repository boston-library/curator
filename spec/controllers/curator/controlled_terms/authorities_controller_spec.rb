# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_formats_and_actions'

RSpec.describe Curator::ControlledTerms::AuthoritiesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # ControlledTerms::Authority. As you add validations to ControlledTerms::Authority, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:valid_session) { {} }

  let!(:serializer_class) { Curator::ControlledTerms::AuthoritySerializer }
  let!(:resource) { create(:curator_controlled_terms_authority) }
  let!(:resource_key) { 'authority' }
  let!(:base_params) { {} }

  include_examples 'shared_formats', has_member_methods: false

  skip "POST #create" do
    context "with valid params" do
      it "creates a new Curator::ControlledTerms::Authority" do
        expect {
          post :create, params: { controlled_terms_authority: valid_attributes }, session: valid_session
        }.to change(Curator::ControlledTerms::Authority, :count).by(1)
      end

      it "renders a JSON response with the new controlled_terms_authority" do
        post :create, params: { controlled_terms_authority: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(controlled_terms_authority_url(Curator::ControlledTerms::Authority.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new controlled_terms_authority" do
        post :create, params: { controlled_terms_authority: invalid_attributes }, session: valid_session
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

      it "updates the requested controlled_terms_authority" do
        authority = Curator::ControlledTerms::Authority.create! valid_attributes
        put :update, params: { id: authority.to_param, controlled_terms_authority: new_attributes }, session: valid_session
        authority.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the controlled_terms_authority" do
        authority = Curator::ControlledTerms::Authority.create! valid_attributes

        put :update, params: { id: authority.to_param, controlled_terms_authority: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the controlled_terms_authority" do
        authority = Curator::ControlledTerms::Authority.create! valid_attributes

        put :update, params: { id: authority.to_param, controlled_terms_authority: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
