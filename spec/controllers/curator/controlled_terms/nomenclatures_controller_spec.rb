# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ControlledTerms::NomenclaturesController, type: :controller do
  # This should return the minimal set of attributes required to create a valid
  # ControlledTerms::Nomenclature. As you add validations to ControlledTerms::Nomenclature, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }
  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }
  let(:valid_session) { {} }

  Curator.controlled_terms.nomenclature_types.map(&:underscore).each do |nomenclature_type|
    context "with :type as #{nomenclature_type}" do
      let!(:serializer_class) { "Curator::ControlledTerms::#{nomenclature_type.classify}Serializer".safe_constantize }
      let!(:resource) { create("curator_controlled_terms_#{nomenclature_type}".to_sym) }
      let!(:base_params) { { type: nomenclature_type } }

      include_examples 'shared_formats', has_collection_methods: false, resource_key: nomenclature_type
    end
  end

  skip "POST #create" do
    context "with valid params" do
      it "creates a new Curator::ControlledTerms::Nomenclature" do
        expect {
          post :create, params: { controlled_terms_nomenclature: valid_attributes }, session: valid_session
        }.to change(Curator::ControlledTerms::Nomenclature, :count).by(1)
      end

      it "renders a JSON response with the new controlled_terms_nomenclature" do
        post :create, params: { controlled_terms_nomenclature: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:created)
        expect(response.content_type).to eq('application/json')
        expect(response.location).to eq(controlled_terms_nomenclature_url(Curator::ControlledTerms::Nomenclature.last))
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the new controlled_terms_nomenclature" do
        post :create, params: { controlled_terms_nomenclature: invalid_attributes }, session: valid_session
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

      it "updates the requested controlled_terms_nomenclature" do
        nomenclature = Curator::ControlledTerms::Nomenclature.create! valid_attributes
        put :update, params: { id: nomenclature.to_param, controlled_terms_nomenclature: new_attributes }, session: valid_session
        nomenclature.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the controlled_terms_nomenclature" do
        nomenclature = Curator::ControlledTerms::Nomenclature.create! valid_attributes

        put :update, params: { id: nomenclature.to_param, controlled_terms_nomenclature: valid_attributes }, session: valid_session
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the controlled_terms_nomenclature" do
        nomenclature = Curator::ControlledTerms::Nomenclature.create! valid_attributes

        put :update, params: { id: nomenclature.to_param, controlled_terms_nomenclature: invalid_attributes }, session: valid_session
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
