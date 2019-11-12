# frozen_string_literal: true

require 'rails_helper'

module Curator
  RSpec.describe DigitalObjectsController, type: :routing do
    describe 'routing' do
      it 'routes to #index' do
        expect(:get => '/digital_objects').to route_to('curator/digital_objects#index')
      end

      it 'routes to #show' do
        expect(:get => '/digital_objects/1').to route_to('curator/digital_objects#show', :id => '1')
      end

      it 'routes to #create' do
        expect(:post => '/digital_objects').to route_to('curator/digital_objects#create')
      end

      it 'routes to #update via PUT' do
        expect(:put => '/digital_objects/1').to route_to('curator/digital_objects#update', :id => '1')
      end

      it 'routes to #update via PATCH' do
        expect(:patch => '/digital_objects/1').to route_to('curator/digital_objects#update', :id => '1')
      end

      it 'routes to #destroy' do
        expect(:delete => '/digital_objects/1').to route_to('curator/digital_objects#destroy', :id => '1')
      end
    end
  end
end
