# frozen_string_literal: true

require 'rails_helper'


RSpec.describe Curator::Filestreams::FileSetsController, type: :controller do
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  let(:valid_session) { {} }


  skip "POST #create" do
    context "with valid params" do
      it "creates a new Curator::Filestreams::FileSet" do
        expect {
          post :create, params: { filestreams_file_set: valid_attributes }, session: valid_session
        }.to change(Curator::Filestreams::FileSet, :count).by(1)
      end

      it "renders a JSON response with the new controlled_terms_authority" do
        post :create, params: { filestreams_file_set: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        # expect(response.location).to eq(controlled_terms_authority_url(Curator::ControlledTerms::Authority.last))
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
        file_set = Curator::FileStreams::FileSet.create! valid_attributes
        put :update, params: { id: file_set.to_param, filestreams_file_set: new_attributes }, session: valid_session
        file_set.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the controlled_terms_authority" do
        file_set = Curator::FileStreams::FileSet.create! valid_attributes

        put :update, params: { id: file_set.to_param, filestreams_file_set: new_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the controlled_terms_authority" do
        file_set = Curator::FileStreams::FileSet.create! valid_attributes

        put :update, params: { id: dile_set.to_param, filestreams_file_set: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
