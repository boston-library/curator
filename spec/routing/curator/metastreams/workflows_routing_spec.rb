# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Metastreams::WorkflowsController, type: :routing do
  routes { Curator::Engine.routes }

  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:ark_id) { 'commonwealth:abcdef123' }
  let!(:default_controller) { 'curator/metastreams/workflows' }

  describe 'default routing' do
    describe 'member routes' do
      context '#workflowable' do
        context 'Institution' do
          include_examples 'metastreamable_member' do
            subject { institution_workflow_path(default_id) }
            let(:expected_controller) { default_controller }
            let(:expected_id) { default_id }
            let(:expected_format) { default_format }
            let(:expected_metastreamable_type) { 'Institution' }
          end

          context '#ark_id as :id' do
            include_examples 'metastreamable_member' do
              subject { institution_workflow_path(ark_id) }
              let(:expected_controller) { default_controller }
              let(:expected_id) { ark_id }
              let(:expected_format) { default_format }
              let(:expected_metastreamable_type) { 'Institution' }
            end
          end
        end

        context 'Collection' do
          include_examples 'metastreamable_member' do
            subject { collection_workflow_path(default_id) }
            let(:expected_controller) { default_controller }
            let(:expected_id) { default_id }
            let(:expected_format) { default_format }
            let(:expected_metastreamable_type) { 'Collection' }
          end

          context '#ark_id as :id' do
            include_examples 'metastreamable_member' do
              subject { collection_workflow_path(ark_id) }
              let(:expected_controller) { default_controller }
              let(:expected_id) { ark_id }
              let(:expected_format) { default_format }
              let(:expected_metastreamable_type) { 'Collection' }
            end
          end
        end

        context 'DigitalObject' do
          include_examples 'metastreamable_member' do
            subject { digital_object_workflow_path(default_id) }
            let(:expected_controller) { default_controller }
            let(:expected_id) { default_id }
            let(:expected_format) { default_format }
            let(:expected_metastreamable_type) { 'DigitalObject' }
          end

          context '#ark_id as :id' do
            include_examples 'metastreamable_member' do
              subject { digital_object_workflow_path(ark_id) }
              let(:expected_controller) { default_controller }
              let(:expected_id) { ark_id }
              let(:expected_format) { default_format }
              let(:expected_metastreamable_type) { 'DigitalObject' }
            end
          end
        end

        Curator.filestreams.file_set_types.map(&:downcase).each do |file_set_type|
          context "#{file_set_type.camelize}" do
            include_examples 'sti_member' do
              subject { filestreams_file_set_workflow_path(default_id, type: file_set_type) }
              let(:expected_controller) { default_controller }
              let(:expected_id) { default_id }
              let(:expected_type) { file_set_type }
              let(:expected_format) { default_format }
            end

            context '#ark_id as :id' do
              include_examples 'sti_member' do
                subject { filestreams_file_set_workflow_path(ark_id, type: file_set_type) }
                let(:expected_controller) { default_controller }
                let(:expected_id) { ark_id }
                let(:expected_type) { file_set_type }
                let(:expected_format) { default_format }
              end
            end
          end
        end
      end
    end
  end
end
