# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ControlledTerms::NomenclaturesController, type: :routing do
  routes { Curator::Engine.routes }

  describe 'default routing' do
    Curator.controlled_terms.nomenclature_types.map(&:downcase).each do |nom_type|
      it 'routes to #index' do
        expect(:get => "/api/controlled_terms/#{nom_type}").to route_to('curator/controlled_terms/nomenclatures#index', :type => nom_type, :format => :json)
      end

      it 'routes to #show' do
        expect(:get => "/api/controlled_terms/#{nom_type}/1").to route_to('curator/controlled_terms/nomenclatures#show', :id => '1', :type => nom_type, :format => :json)
      end

      it 'routes to #create' do
        expect(:post => "/api/controlled_terms/#{nom_type}").to route_to('curator/controlled_terms/nomenclatures#create', :type => nom_type, :format => :json)
      end

      it 'routes to #update via PUT' do
        expect(:put => "/api/controlled_terms/#{nom_type}/1").to route_to('curator/controlled_terms/nomenclatures#update', :id => '1', :type => nom_type, :format => :json)
      end

      it 'routes to #update via PATCH' do
        expect(:patch => "/api/controlled_terms/#{nom_type}/1").to route_to('curator/controlled_terms/nomenclatures#update', :id => '1', :type => nom_type, :format => :json)
      end

      # TODO implement this using soft delete
      skip "routes to #destroy" do
        expect(:delete => "/api/controlled_terms/#{nom_type}/1").to route_to("controlled_terms/nomenclatures#destroy", :id => "1", :format => :json)
      end
    end
  end
end
