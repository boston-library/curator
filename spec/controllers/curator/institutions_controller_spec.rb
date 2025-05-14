# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/shared_formats_and_actions'

RSpec.describe Curator::InstitutionsController, type: :controller do
  let!(:resource) { create(:curator_institution, :with_location) }
  let!(:valid_attributes) do
    attributes = attributes_for(:curator_institution, :with_location).except(:administrative, :workflow)
    relation_attributes = load_json_fixture('institution')
    attributes.merge!({
      location: relation_attributes.dup.delete('location'),
      metastreams: relation_attributes.dup.delete('metastreams')
    })
  end

  let!(:valid_update_attributes) do
    attributes = resource.attributes.slice('abstract', 'url').symbolize_keys
    location = create(:curator_controlled_terms_geographic)
    admin_set = create(:curator_collection, institution: resource)
    digital_object = create(:curator_digital_object, admin_set: admin_set)
    image_file = create(:curator_filestreams_image, file_set_of: digital_object)
    attributes[:exemplary_file_set] = { ark_id: image_file.ark_id }

    attributes[:location] = {
      label: location.label,
      id_from_auth: location.id_from_auth,
      coordinates: location.coordinates,
      authority_code: location.authority_code,
      bounding_box: location.bounding_box,
      area_type: location.area_type
    }
    attributes[:host_collections_attributes] = [
      { name: 'Host Collection One' },
      { name: 'Host Collection Two' }
    ]
    attributes
  end

  let(:valid_session) { {} }
  let(:base_params) { {} }
  let(:invalid_attributes) { valid_attributes.dup.update(name: nil) }
  let(:invalid_update_attributes) { valid_update_attributes.dup.update(url: 'xyz://foo.bar.org') }
  let(:resource_class) { Curator::Institution }
  let(:serializer_class) { Curator::InstitutionSerializer }

  include_examples 'shared_formats', include_ark_context: true, skip_put_patch: false, skip_post: false, resource_key: 'institution'
end
