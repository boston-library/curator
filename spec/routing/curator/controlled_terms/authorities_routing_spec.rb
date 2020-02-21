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
      include_examples 'collection' do
        subject { controlled_terms_authorities_path }
        let(:expected_controller) { default_controller }
        let(:expected_format) { default_format }
      end
    end

    describe 'member routes' do
      include_examples 'member' do
        subject { controlled_terms_authority_path(default_id) }
        let(:expected_controller) { default_controller }
        let(:expected_id) { default_id }
        let(:expected_format) { default_format }
      end
    end
  end
end
