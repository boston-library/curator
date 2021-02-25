# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_routing'

RSpec.describe Curator::Metastreams::AdministrativesController, type: :routing do
  routes { Curator::Engine.routes }

  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:ark_id) { 'bpl-dev:abcdef123' }
  let!(:default_controller) { 'curator/metastreams/administratives' }

  describe 'default routing' do
    describe 'member routes' do
      context '#administratable' do
        ['Institution', 'Collection', 'DigitalObject'].each do |metastreamable_type|
          context "#{metastreamable_type}" do
            include_examples 'member' do
              subject { public_send("#{metastreamable_type.underscore}_administrative_path", default_id) }
              let(:expected_controller) { default_controller }
              let(:expected_kwargs) { { id: default_id, metastreamable_type: metastreamable_type, format: default_format } }
            end

            context '#ark_id as :id' do
              include_examples 'member' do
                subject { public_send("#{metastreamable_type.underscore}_administrative_path", ark_id) }
                let(:expected_controller) { default_controller }
                let(:expected_kwargs) { { id: ark_id, metastreamable_type: metastreamable_type, format: default_format } }
              end
            end
          end
        end


        Curator.filestreams.file_set_types.map(&:downcase).each do |file_set_type|
          context "#{file_set_type.camelize}" do
            include_examples 'member' do
              subject { filestreams_file_set_administrative_path(default_id, type: file_set_type) }
              let(:expected_controller) { default_controller }
              let(:expected_kwargs) { { id: default_id, type: file_set_type, metastreamable_type: 'Filestreams::FileSet', format: default_format } }
            end

            context '#ark_id as :id' do
              include_examples 'member' do
                subject { filestreams_file_set_administrative_path(ark_id, type: file_set_type) }
                let(:expected_controller) { default_controller }
                let(:expected_kwargs) { { id: ark_id, type: file_set_type, metastreamable_type: 'Filestreams::FileSet', format: default_format } }
              end
            end
          end
        end
      end
    end
  end
end
