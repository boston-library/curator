# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::CollectionsController, type: :controller do
  let!(:resource) { create(:curator_collection) }
  let!(:valid_attributes) do
    attributes = attributes_for(:curator_collection).except(:administrative, :workflow)
    relation_attributes = load_json_fixture('collection')
    parent = create(:curator_institution, :with_location)
    attributes.merge!({
      institution: { ark_id: parent.ark_id },
      metastreams: relation_attributes.dup.delete('metastreams')
    })
  end

  let!(:valid_update_attributes) do
    digital_object = create(:curator_digital_object, admin_set: resource)
    image_file = create(:curator_filestreams_image, file_set_of: digital_object)
    attributes = {}
    attributes[:abstract] = resource.abstract
    attributes[:exemplary_file_set] = { ark_id: image_file.ark_id }
    attributes
  end


  let(:valid_session) { {} }
  let(:base_params) { {} }
  let(:invalid_attributes) { valid_attributes.dup.update(name: nil) }
  let(:invalid_update_attributes) { valid_update_attributes.dup.update(abstract: nil) }
  let(:resource_class) { Curator::Collection }
  let(:serializer_class) { Curator::CollectionSerializer }


  include_examples 'shared_formats', include_ark_context: true, skip_put_patch: false, skip_post: false, resource_key: 'collection'
end
