# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_formats_and_actions'

RSpec.describe Curator::Metastreams::WorkflowsController, type: :controller do
  # let(:valid_session) { {} }
  #
  # let(:valid_attributes) {
  #   skip("Add a hash of attributes valid for your model")
  # }
  #
  # let(:invalid_attributes) {
  #   skip("Add a hash of attributes invalid for your model")
  # }

  let!(:serializer_class) { Curator::Metastreams::WorkflowSerializer }

  ['Institution', 'Collection', 'DigitalObject'].each do |metastreamable_type|
    context "with :metastreamable_type as #{metastreamable_type}" do
      let!(:parent_resource) { create("curator_#{metastreamable_type.underscore}", :with_metastreams) }
      let!(:resource) { parent_resource.workflow }
      let!(:resource_key) { 'workflow' }
      let!(:base_params) do
        {
          metastreamable_type: metastreamable_type,
          ark_id: parent_resource.ark_id,
          id: parent_resource.to_param
        }
      end

      include_examples 'shared_formats', include_ark_context: true, has_collection_methods: false
    end
  end

  context 'with :metastreamable_type as Filestreams::FileSet' do
    let!(:metastreamable_type) { 'Filestreams::FileSet' }

    Curator.filestreams.file_set_types.map(&:underscore).each do |file_set_type|
      context "with :type as #{file_set_type}" do
        let!(:parent_resource) { create("curator_filestreams_#{file_set_type}", :with_metastreams) }
        let!(:resource) { parent_resource.workflow }
        let!(:resource_key) { 'workflow' }
        let!(:base_params) do
          {
            metastreamable_type: metastreamable_type,
            type: file_set_type,
            ark_id: parent_resource.ark_id,
            id: parent_resource.to_param
          }
        end

        include_examples 'shared_formats', include_ark_context: true, has_collection_methods: false
      end
    end
  end
end
