# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_formats_and_actions'

RSpec.describe Curator::Metastreams::DescriptivesController, type: :controller do
  # let(:valid_session) { {} }
  #
  # let(:valid_attributes) {
  #   skip("Add a hash of attributes valid for your model")
  # }
  #
  # let(:invalid_attributes) {
  #   skip("Add a hash of attributes invalid for your model")
  # }
  let!(:metastreamable_type) { 'DigitalObject' }
  let!(:serializer_class) { Curator::Metastreams::DescriptiveSerializer }
  let!(:parent_resource) { create(:curator_digital_object) }
  let!(:resource) { parent_resource.descriptive }
  let!(:resource_key) { 'descriptive' }
  let!(:base_params) do
    {
      metastreamable_type: metastreamable_type,
      ark_id: parent_resource.ark_id,
      id: parent_resource.to_param
    }
  end
  context "with :metastreamable_type as DigitalObject" do
    include_examples 'shared_formats', include_ark_context: true, has_collection_methods: false
  end
end
