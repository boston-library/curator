require 'rails_helper'

module Curator
  RSpec.describe Metastreams::AdministrativesController, type: :controller do

    describe "GET #update" do
      it "returns http success" do
        get :update
        expect(response).to have_http_status(:success)
      end
    end

  end
end
