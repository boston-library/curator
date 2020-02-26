# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_formats_and_actions'

RSpec.describe Curator::Metastreams::AdministrativesController, type: :controller do
  # let(:valid_session) { {} }
  #
  # let(:valid_attributes) {
  #   skip("Add a hash of attributes valid for your model")
  # }
  #
  # let(:invalid_attributes) {
  #   skip("Add a hash of attributes invalid for your model")
  # }

  let!(:serializer_class) { Curator::Metastreams::AdministrativeSerializer }
  let!(:parent_resource) { create(:curator_institution, :with_metastreams) }
  let!(:resource) { parent_resource.administrative }
  let!(:resource_key) { 'administrative' }
  let!(:base_params) do
    {
      metastreamable_type: 'Institution',
      ark_id: parent_resource.ark_id,
      id: parent_resource.to_param
    }
  end

  include_examples 'shared_formats', include_ark_context: true, has_collection_methods: false
end
