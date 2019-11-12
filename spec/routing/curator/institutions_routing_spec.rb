# frozen_string_literal: true

require 'rails_helper'

module Curator
  RSpec.describe InstitutionsController, type: :routing do
    describe 'routing' do
      it 'routes to #index' do
        expect(:get => '/institutions').to route_to('curator/institutions#index')
      end

      it 'routes to #show' do
        expect(:get => '/institutions/1').to route_to('curator/institutions#show', :id => '1')
      end

      it 'routes to #create' do
        expect(:post => '/institutions').to route_to('curator/institutions#create')
      end

      it 'routes to #update via PUT' do
        expect(:put => '/institutions/1').to route_to('curator/institutions#update', :id => '1')
      end

      it 'routes to #update via PATCH' do
        expect(:patch => '/institutions/1').to route_to('curator/institutions#update', :id => '1')
      end

      it 'routes to #destroy' do
        expect(:delete => '/institutions/1').to route_to('curator/institutions#destroy', :id => '1')
      end
    end
  end
end
