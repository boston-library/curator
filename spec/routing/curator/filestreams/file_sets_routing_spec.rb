# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_routing'

RSpec.describe Curator::Filestreams::FileSetsController, type: :routing do
  routes { Curator::Engine.routes }

  let!(:default_format) { :json }
  let!(:default_id) { '1' }
  let!(:ark_id) { 'bpl-dev:abcdef123' }
  let!(:default_controller) { 'curator/filestreams/file_sets' }

  describe 'default routing' do
    Curator.filestreams.file_set_types.map(&:downcase).each do |file_set_type|
      describe "#{file_set_type.classify} collection routes" do
        include_examples 'collection' do
          subject { filestreams_file_sets_path(type: file_set_type) }
          let(:expected_controller) { default_controller }
          let(:expected_kwargs) { { type: file_set_type, format: default_format } }
        end
      end

      describe "#{file_set_type.classify} member routes" do
        include_examples 'member' do
          subject { filestreams_file_set_path(default_id, type: file_set_type) }
          let(:expected_controller) { default_controller }
          let(:expected_kwargs) { { id: default_id, type: file_set_type, format: default_format } }
        end

        context '#ark_id as :id' do
          include_examples 'member' do
            subject { filestreams_file_set_path(ark_id, type: file_set_type) }
            let(:expected_controller) { default_controller }
            let(:expected_kwargs) { { id: ark_id, type: file_set_type, format: default_format } }
          end
        end
      end
    end
  end
end
