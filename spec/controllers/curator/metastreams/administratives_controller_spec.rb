# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::AdministrativesController, type: :controller do
  skip "GET #update" do
    it "returns http success" do
      get :update
      expect(response).to have_http_status(:success)
    end
  end
end
