# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'
RSpec.describe Curator::InstitutionSerializer, type: :serializers do
  let!(:institution_count) { 3 }

  let!(:record_collection) do
    insts = create_list(:curator_institution, institution_count, :with_location)
    Curator.institution_class.where(id: insts.pluck(:id)).for_serialization
  end

  let!(:record)  { record_collection.last }

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end

  describe 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:record_root_key) { :institution }
      let(:expected_json) do
        proc do |resource|
          Alba.serialize(resource) do
            root_key :institution, :institutions

            attributes :ark_id, :created_at, :updated_at, :name, :abstract, :url

            has_one :location do
              attributes :area_type, :coordinates, :bounding_box, :authority_code, :label, :id_from_auth
            end

            has_one :administrative do
              attributes :description_standard, :harvestable, :flagged, :destination_site, :hosting_status
            end

            has_one :workflow do
              attributes :publishing_state, :processing_state, :ingest_origin
            end
          end
        end
      end
    end
  end
end
