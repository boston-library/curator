require 'rails_helper'

module Curator
  RSpec.describe Metastreams::DescriptivesController, type: :controller do

    describe "GET #update" do
      it "returns http success" do
        get :update
        expect(response).to have_http_status(:success)
      end
    end

  end
end
