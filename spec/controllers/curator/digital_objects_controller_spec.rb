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
    admin_set = create(:curator_collection)
    digital_object = create(:digital_object, admin_set: admin_set)
    exemplary_image = create_list(:image_file_set, file_set_of: digital_object)

    attributes = {}
    attributes[]

  end

  let(:valid_session) { {} }
  let(:base_params) { {} }
  let(:invalid_attributes) { valid_attributes.dup.update(admin_set: {}) }
  let(:invalid_update_attributes) { valid_attributes.dup.update(admin_set: {}) }
  let(:resource_class) { Curator::DigitalObject }
  let(:serializer_class) { Curator::DigitalObjectSerializer }

  include_examples 'shared_formats', include_ark_context: true, skip_post: false, resource_key: 'digital_object'
end
