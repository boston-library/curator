# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::DescriptivesController, type: :routing do
  routes { Curator::Engine.routes }

  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:ark_id) { 'bpl-dev:abcdef123' }
  let!(:default_controller) { 'curator/metastreams/descriptives' }

  describe 'default routing' do
    describe 'member routes' do
      context '#descriptable' do
        context 'DigitalObject' do
          include_examples 'member' do
            subject { digital_object_descriptive_path(default_id) }
            let(:expected_controller) { default_controller }
            let(:expected_kwargs) { { id: default_id, metastreamable_type: 'DigitalObject', format: default_format } }
          end

          context '#ark_id as :id' do
            include_examples 'member' do
              subject { digital_object_descriptive_path(ark_id) }
              let(:expected_controller) { default_controller }
              let(:expected_kwargs) { { id: ark_id, metastreamable_type: 'DigitalObject', format: default_format } }
            end
          end
        end
      end
    end
  end

  describe 'xml routing' do
    describe 'member routes' do
      context '#descriptable' do
        context 'DigitalObject' do
          include_examples 'member', read_only: true do
            subject { digital_object_descriptive_path(default_id, format: :xml) }
            let(:expected_controller) { default_controller }
            let(:expected_kwargs) { { id: default_id, metastreamable_type: 'DigitalObject', format: 'xml' } }
          end

          context '#ark_id as :id' do
            include_examples 'member', read_only: true do
              subject { digital_object_descriptive_path(ark_id, format: :xml) }
              let(:expected_controller) { default_controller }
              let(:expected_kwargs) { { id: ark_id, metastreamable_type: 'DigitalObject', format: 'xml' } }
            end
          end
        end
      end
    end
  end
end
