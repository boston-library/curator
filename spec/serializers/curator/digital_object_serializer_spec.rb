# frozen_string_literal: true

require 'rails_helper'
require_relative './shared/inherited_serializers'
require_relative './shared/json_serialization'

RSpec.describe Curator::DigitalObjectSerializer, type: :serializers do
  let!(:digital_object_count) { 3 }
  let!(:descriptive_term_counts) { 2 }
  let!(:record) { create(:curator_digital_object, :with_metastreams, :with_contained_by, desc_term_count: descriptive_term_counts) }
  let!(:record_collection) { create_list(:curator_digital_object, digital_object_count, :with_contained_by, :with_metastreams, desc_term_count: descriptive_term_counts) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_serializer'
  end

  skip 'Serialization(Pending)' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_as_json_options) do
        {
          root: true,
          only: [:ark_id, :created_at, :updated_at],
          include: {
            admin_set: {
              only: :ark_id
            },
            contained_by: {
              only: :ark_id
            },
            is_member_of_collection: {
              only: :ark_id
            }
          },
          administrative: {
            root: true,
            only: [:description_standard, :harvestable, :flagged, :destination_site]
          },
          descriptive: {
            root: true
            # only: [:],
            # included: {
            #
            # }
          },
          workflow: {
            root: true,
            only: [:publishing_state, :processing_state, :ingest_origin]
          }
        }
      end
    end
  end
end
