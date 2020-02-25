# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catch all routes', type: :routing do
  routes { Curator::Engine.routes }

  context 'DELETE' do
    let(:default_id) { '1' }
    let(:route_paths) do
      ['Institution', 'Collection', 'DigitalObject'].map do |resource_type|
        public_send("#{resource_type.underscore}_path", default_id)
      end
    end
    it 'routes to application#method_not_allowed for any route in api' do
      route_paths.each do |resource_path|
        expect(:delete => resource_path).to route_to("curator/application#method_not_allowed", format: :json, path: resource_path.gsub('/api/', ''))
      end
    end
  end

  context 'GET POST' do
    let(:bad_paths) { ['/api/foo', '/api/phpAdmin', '/api/some_file'] }

    it 'routes to application#not_found for any route not in api' do
      bad_paths.each do |bad_path|
        expect(:get => bad_path).to route_to("curator/application#not_found", format: :json, path: bad_path.gsub('/api/', ''))
        expect(:post => bad_path).to route_to("curator/application#not_found", format: :json, path: bad_path.gsub('/api/', ''))
        expect(:put => bad_path).to route_to("curator/application#not_found", format: :json, path: bad_path.gsub('/api/', ''))
        expect(:post => bad_path).to route_to("curator/application#not_found", format: :json, path: bad_path.gsub('/api/', ''))
      end
    end
  end
end
