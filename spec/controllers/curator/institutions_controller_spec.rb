# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::InstitutionsController, type: :controller do



  let!(:valid_session) { {} }
  let!(:valid_attributes) { load_json_fixture('institution')  }
  let!(:invalid_attributes) { valid_attributes.dup.except('ark_id', 'name') }
  let!(:serializer_class) { Curator::InstitutionSerializer }
  let!(:resource) { create(:curator_institution, :with_location) }
  let!(:resource_class) { Curator::Institution }
  let!(:base_params) { {} }

  include_examples 'shared_formats', include_ark_context: true, skip_post: false, resource_key: 'institution'

  skip 'POST #create' do
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
