# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_formats_and_actions'

RSpec.describe Curator::Metastreams::DescriptivesController, type: :controller do
  let!(:valid_session) { {} }
  let!(:metastreamable_type) { 'DigitalObject' }
  let!(:serializer_class) { Curator::Metastreams::DescriptiveSerializer }
  let!(:parent_resource) { create(:curator_digital_object) }
  let!(:resource) { parent_resource.descriptive }
  let!(:base_params) do
    {
      metastreamable_type: metastreamable_type,
      ark_id: parent_resource.ark_id,
      id: parent_resource.to_param
    }
  end
  let!(:valid_update_attributes) {
    load_json_fixture('digital_object_2', 'digital_object').dig('metastreams', 'descriptive') || {}
  }
  let(:invalid_update_attributes) { valid_update_attributes.dup.update(toc_url: 'xyz://foo.bar.org') }

  context "with :metastreamable_type as DigitalObject" do
    include_examples 'shared_formats', include_ark_context: true, has_collection_methods: false, skip_put_patch: false, resource_key: 'descriptive', has_xml_context: true
  end
end
