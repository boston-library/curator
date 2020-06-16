# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_formats_and_actions'

RSpec.describe Curator::Metastreams::WorkflowsController, type: :controller do
  let!(:serializer_class) { Curator::Metastreams::WorkflowSerializer }
  let!(:valid_session) { {} }

  ['Institution', 'Collection', 'DigitalObject'].each do |metastreamable_type|
    context "with :metastreamable_type as #{metastreamable_type}" do
      let!(:parent_resource) { create("curator_#{metastreamable_type.underscore}") }
      let!(:resource) { parent_resource.workflow }
      let!(:base_params) do
        {
          metastreamable_type: metastreamable_type,
          ark_id: parent_resource.ark_id,
          id: parent_resource.to_param
        }
      end

      let!(:valid_update_attributes) do
        {
          publishing_state: 'published'
        }
      end

      let(:invalid_update_attributes) { valid_update_attributes.dup.update(publishing_state: 'FOO') }

      include_examples 'shared_formats', include_ark_context: true, skip_put_patch: false, has_collection_methods: false, resource_key: 'workflow'
    end
  end

  context 'with :metastreamable_type as Filestreams::FileSet' do
    let!(:metastreamable_type) { 'Filestreams::FileSet' }

    Curator.filestreams.file_set_types.map(&:underscore).each do |file_set_type|
      context "with :type as #{file_set_type}" do
        let!(:parent_resource) { create("curator_filestreams_#{file_set_type}") }
        let!(:resource) { parent_resource.workflow }
        let!(:base_params) do
          {
            metastreamable_type: metastreamable_type,
            type: file_set_type,
            ark_id: parent_resource.ark_id,
            id: parent_resource.to_param
          }
        end

        let!(:valid_update_attributes) do
          {
            processing_state: 'published'
          }
        end

        let(:invalid_update_attributes) { valid_update_attributes.dup.update(processing_state: 'FOO') }

        include_examples 'shared_formats', include_ark_context: true, skip_put_patch: false, has_collection_methods: false, resource_key: 'workflow'
      end
    end
  end
end
