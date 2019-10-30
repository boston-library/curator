require 'rails_helper'

module Curator
  RSpec.describe ControlledTerms::NomenclaturesController, type: :routing do
    describe 'routing' do
      Curator::ControlledTerms.nomenclature_types.map{|nom_type| nom_type.underscore.pluralize}.each do |nom_type|
        it 'routes to #index' do
          expect(:get => "/controlled_terms/#{nom_type}").to route_to('curator/controlled_terms/nomenclatures#index', :type => nom_type.singularize.camelize)
        end

        it 'routes to #show' do
          expect(:get => "/controlled_terms/#{nom_type}/1").to route_to('curator/controlled_terms/nomenclatures#show', :id => '1', :type => nom_type.singularize.camelize)
        end

        it 'routes to #create' do
          expect(:post => "/controlled_terms/#{nom_type}").to route_to('curator/controlled_terms/nomenclatures#create', :type => nom_type.singularize.camelize)
        end

        it 'routes to #update via PUT' do
          expect(:put => "/controlled_terms/#{nom_type}/1").to route_to('curator/controlled_terms/nomenclatures#update', :id => '1', :type => nom_type.singularize.camelize)
        end

        it 'routes to #update via PATCH' do
          expect(:patch => "/controlled_terms/#{nom_type}/1").to route_to('curator/controlled_terms/nomenclatures#update', :id => '1', :type => nom_type.singularize.camelize)
        end

        # TODO implement this using soft delete
        # it "routes to #destroy" do
        #   expect(:delete => "/controlled_terms/nomenclatures/1").to route_to("controlled_terms/nomenclatures#destroy", :id => "1")
        # end
      end
    end
  end
end
