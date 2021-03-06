# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_routing'

RSpec.describe Curator::CollectionsController, type: :routing do
  routes { Curator::Engine.routes }

  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:ark_id) { 'bpl-dev:abcdef123' }
  let!(:default_controller) { 'curator/collections' }

  describe 'default routing' do
    describe 'collection routes' do
      include_examples 'collection' do
        subject { collections_path }
        let(:expected_controller) { default_controller }
        let(:expected_kwargs) { { format: default_format } }
      end
    end

    describe 'member routes' do
      include_examples 'member' do
        subject { collection_path(default_id) }
        let(:expected_controller) { default_controller }
        let(:expected_kwargs) { { id: default_id, format: default_format } }
      end

      context '#ark_id as :id' do
        include_examples 'member' do
          subject { collection_path(ark_id) }
          let(:expected_controller) { default_controller }
          let(:expected_kwargs) { { id: ark_id, format: default_format } }
        end
      end
    end
  end
end
