# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/json_serialization'

RSpec.describe Curator::Metastreams::DescriptiveSerializer, type: :serializers do
  let!(:descriptive_count) { 3 }
  let!(:desc_term_counts) { 3 }
  let!(:record) { create(:curator_metastreams_descriptive) }
  let!(:record_collection) { create_list(:curator_metastreams_descriptive, descriptive_count) }

  skip 'Serialization' do
    it_behaves_like 'json_serialization' do
      let(:json_record) { record }
      let(:json_array) { record_collection }
      let(:expected_as_json_options) do
        {
          root: true,
          only: [:abstract, :digital_origin, :origin_event, :text_direction, :resource_type_manuscript, :place_of_publication, :publisher, :issuance, :frequency, :extent, :physical_location_department, :physical_location_shelf_locator, :series, :subseries, :subsubseries, :rights, :access_restrictions, :toc, :toc_url],
          include: {
            physical_location: {
              only: [:label, :id_from_auth, :authority_code, :affiliation, :name_type],
              methods: [:label, :id_from_auth, :authority_code, :affiliation, :name_type]
            },
            identifier: {
              only: [:label, :type, :invalid],
              methods: [:label, :type, :invalid]
            },
            title: {
              only: [:primary, :other],
              methods: [:primary, :other]
            }
          }
        }
      end
    end
  end
end
