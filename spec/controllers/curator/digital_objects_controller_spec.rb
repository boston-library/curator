# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::DigitalObjectsController, type: :controller do
  let!(:resource) { create(:curator_digital_object) }
  let!(:valid_attributes) do
    attributes = attributes_for(:curator_digital_object).except(:administrative, :descriptive, :workflow)
    relation_attributes = load_json_fixture('digital_object')
    parent = create(:curator_collection, institution: create(:curator_institution, :with_location))

    attributes.merge!({
        admin_set: { ark_id: parent.ark_id },
        is_member_of_collection: [{ ark_id: parent.ark_id }],
        metastreams: relation_attributes.dup.delete('metastreams')
      })
  end

  let!(:valid_update_attributes) do
    attributes = {}
    member_to_add = create(:curator_collection, institution: resource.institution)
    member_to_remove = create(:curator_collection, institution: resource.institution)
    exemplary_image = create(:curator_filestreams_image, file_set_of: resource)

    create(:curator_mappings_collection_member, digital_object: resource, collection: member_to_remove)

    attributes.merge!({
        is_member_of_collection: [{ ark_id: member_to_add.ark_id }, { ark_id: member_to_remove.ark_id, _destroy: '1' } ],
        exemplary_file_set: {
          ark_id: exemplary_image.ark_id
        }
    })
  end

  let(:valid_session) { {} }
  let(:base_params) { {} }
  let(:invalid_attributes) { valid_attributes.dup.update(admin_set: {}) }
  let(:invalid_update_attributes) { valid_update_attributes.dup.update(is_member_of_collection: [{ ark_id: resource.admin_set.ark_id, _destroy: '1' }]) }
  let(:resource_class) { Curator::DigitalObject }
  let(:serializer_class) { Curator::DigitalObjectSerializer }

  include_examples 'shared_formats', include_ark_context: true, skip_put_patch: false, skip_post: false, resource_key: 'digital_object'
end
