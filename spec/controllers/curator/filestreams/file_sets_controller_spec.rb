# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_formats_and_actions'

RSpec.describe Curator::Filestreams::FileSetsController, type: :controller do
  let!(:parent_col) { create(:curator_collection) }
  let!(:parent_obj) { create(:curator_digital_object, admin_set: parent_col) }

  Curator.filestreams.file_set_types.map(&:downcase).each do |file_set_type|

    describe "As #{file_set_type.camelize}" do
      let(:resource) { create("curator_filestreams_#{file_set_type}", file_set_of: parent_obj) }

      let(:valid_attributes) do
        attributes = attributes_for("curator_filestreams_#{file_set_type}").except(:administrative, :workflow)
        relation_attributes = load_json_fixture('image_file_set', 'file_set')
        attributes[:file_set_type] = file_set_type
        attributes[:exemplary_image_of] = [{ ark_id: parent_col.ark_id }] if can_be_exemplary?(file_set_type.camelize)
        attributes.merge!({
                   file_set_of: { ark_id: parent_obj.ark_id },
                   metastreams: relation_attributes.dup.delete('metastreams')
          })
      end

      let(:valid_update_attributes) do
        attributes = {}
        attributes[:position] = 2
        attributes[:pagination] = { page_label: '3', page_type: 'TOC', hand_side: 'left' }
        if can_be_exemplary?(file_set_type)
          attributes[:exemplary_image_of] = [{ ark_id: parent_obj.ark_id, _destroy: '1' }, { ark_id: parent_col.ark_id }]
        end
        attributes
      end

      let(:valid_session) { {} }
      let(:base_params) { { type: file_set_type } }
      let(:invalid_attributes) { valid_attributes.dup.update(file_name_base: nil) }
      let(:invalid_update_attributes) { { pagination: { hand_side: 'foo'} } }
      let(:resource_class) { "Curator::Filestreams::#{file_set_type.capitalize}".constantize }
      let(:serializer_class) { "Curator::Filestreams::#{file_set_type.capitalize}Serializer".constantize }

      include_examples 'shared_formats', include_ark_context: true, skip_post: false, skip_put_patch: false, resource_key: 'file_set'
    end
  end
end
