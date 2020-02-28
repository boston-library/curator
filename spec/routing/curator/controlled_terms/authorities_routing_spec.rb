# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_routing'

RSpec.describe Curator::ControlledTerms::AuthoritiesController, type: :routing do
  routes { Curator::Engine.routes }

  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:default_controller) { 'curator/controlled_terms/authorities' }

  describe 'default routing' do
    describe 'collection routes' do
      include_examples 'collection', read_only: true do
        subject { controlled_terms_authorities_path }
        let(:expected_controller) { default_controller }
        let(:expected_format) { default_format }
        let(:expected_kwargs) { { format: default_format } }
      end
    end
  end
end
