# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/shared_formats_and_actions'

RSpec.describe Curator::Filestreams::FileSetsController, type: :controller do
  let!(:parent_col) { create(:curator_collection, institution: create(:curator_institution, :with_location)) }
  let!(:parent_obj) { create(:curator_digital_object, admin_set: parent_col) }

  Curator.filestreams.file_set_types.map(&:downcase).each do |file_set_type|
    describe "As #{file_set_type.capitalize}" do
      let!(:resource) { create("curator_filestreams_#{file_set_type}") }
      let!(:valid_attributes) do
        attributes = attributes_for("curator_filestreams_#{file_set_type}").except(:administrative, :workflow)
        attributes[:file_set_type] = file_set_type
        relation_attributes = load_json_fixture('image_file_set', 'file_set')

        attributes.merge!({
                   file_set_of: { ark_id: parent_obj.ark_id },
                   exemplary_image_of: [{ ark_id: parent_col.ark_id }, { ark_id: parent_obj.ark_id }],
                   metastreams: relation_attributes.dup.delete('metastreams')
          })
      end

      let(:valid_session) { {} }
      let(:base_params) { { type: file_set_type } }
      let(:invalid_attributes) { valid_attributes.dup.update(file_name_base: nil) }
      let(:resource_class) { "Curator::Filestreams::#{file_set_type.capitalize}".constantize }
      let(:serializer_class) { "Curator::Filestreams::#{file_set_type.capitalize}Serializer".constantize }

      include_examples 'shared_formats', include_ark_context: true, skip_post: false, resource_key: 'file_set'
    end
  end


  skip "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested controlled_terms_authority" do
        file_set = create(:curator_filestreams_file_set)
        put :update, params: { id: file_set.to_param, filestreams_file_set: new_attributes }, session: {}
        file_set.reload
        skip("Add assertions for updated state")
      end

      it "renders a JSON response with the controlled_terms_authority" do
        file_set = create(:curator_filestreams_file_set)

        put :update, params: { id: file_set.to_param, filestreams_file_set: new_attributes }, session: {}
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to eq('application/json')
      end
    end

    context "with invalid params" do
      it "renders a JSON response with errors for the controlled_terms_authority" do
        file_set = create(:curator_filestreams_file_set)

        put :update, params: { id: dile_set.to_param, filestreams_file_set: {} }, session: {}
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to eq('application/json')
      end
    end
  end
end
