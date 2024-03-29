# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_routing'

RSpec.describe Curator::DigitalObjectsController, type: :routing do
  routes { Curator::Engine.routes }

  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:ark_id) { 'bpl-dev:abcdef123' }
  let!(:default_controller) { 'curator/digital_objects' }

  describe 'default routing' do
    describe 'collection routes' do
      include_examples 'collection' do
        subject { digital_objects_path }
        let(:expected_controller) { default_controller }
        let(:expected_kwargs) { { format: default_format } }
      end
    end

    describe 'member routes' do
      include_examples 'member' do
        subject { digital_object_path(default_id) }
        let(:expected_controller) { default_controller }
        let(:expected_kwargs) { { id: default_id, format: default_format } }
      end

      context '#ark_id as :id' do
        include_examples 'member' do
          subject { digital_object_path(ark_id) }
          let(:expected_controller) { default_controller }
          let(:expected_kwargs) { { id: ark_id, format: default_format } }
        end
      end
    end

    describe 'xml-mods routing' do
      describe 'member routes' do
        include_examples 'member', read_only: true do
          subject { digital_object_path(default_id, format: :xml) }
          let(:expected_controller) { default_controller }
          let(:expected_kwargs) { { id: default_id, format: 'xml' } }
        end

        context '#ark_id as :id' do
          include_examples 'member', read_only: true do
            subject { digital_object_path(ark_id, format: :xml) }
            let(:expected_controller) { default_controller }
            let(:expected_kwargs) { { id: ark_id, format: 'xml' } }
          end
        end
      end
    end
  end
end
