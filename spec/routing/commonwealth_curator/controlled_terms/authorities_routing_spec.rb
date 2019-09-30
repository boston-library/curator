require "rails_helper"

module Curator
  RSpec.describe ControlledTerms::AuthoritiesController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(:get => "/controlled_terms/authorities").to route_to("controlled_terms/authorities#index")
      end

      it "routes to #show" do
        expect(:get => "/controlled_terms/authorities/1").to route_to("controlled_terms/authorities#show", :id => "1")
      end


      it "routes to #create" do
        expect(:post => "/controlled_terms/authorities").to route_to("controlled_terms/authorities#create")
      end

      it "routes to #update via PUT" do
        expect(:put => "/controlled_terms/authorities/1").to route_to("controlled_terms/authorities#update", :id => "1")
      end

      it "routes to #update via PATCH" do
        expect(:patch => "/controlled_terms/authorities/1").to route_to("controlled_terms/authorities#update", :id => "1")
      end

      it "routes to #destroy" do
        expect(:delete => "/controlled_terms/authorities/1").to route_to("controlled_terms/authorities#destroy", :id => "1")
      end
    end
  end
end
