require "rails_helper"

module CommonwealthCurator
  RSpec.describe ControlledTerms::NomenclaturesController, type: :routing do
    describe "routing" do
      it "routes to #index" do
        expect(:get => "/controlled_terms/nomenclatures").to route_to("controlled_terms/nomenclatures#index")
      end

      it "routes to #show" do
        expect(:get => "/controlled_terms/nomenclatures/1").to route_to("controlled_terms/nomenclatures#show", :id => "1")
      end


      it "routes to #create" do
        expect(:post => "/controlled_terms/nomenclatures").to route_to("controlled_terms/nomenclatures#create")
      end

      it "routes to #update via PUT" do
        expect(:put => "/controlled_terms/nomenclatures/1").to route_to("controlled_terms/nomenclatures#update", :id => "1")
      end

      it "routes to #update via PATCH" do
        expect(:patch => "/controlled_terms/nomenclatures/1").to route_to("controlled_terms/nomenclatures#update", :id => "1")
      end

      it "routes to #destroy" do
        expect(:delete => "/controlled_terms/nomenclatures/1").to route_to("controlled_terms/nomenclatures#destroy", :id => "1")
      end
    end
  end
end
