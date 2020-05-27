# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Filestreams::FileSetUpdaterService, type: :service do
  before(:all) do
    @collection ||= create(:curator_collection)
    @digital_object ||= create(:curator_digital_object, admin_set: @collection)
    @file_set ||= create(:curator_filestreams_image, file_set_of: @digital_object)

    create(:curator_mappings_exemplary_image, exemplary_object: @collection, exemplary_file_set: @file_set)

    @update_attributes ||= {
      position: 2,
      pagination: { page_size: '4', page_type: 'TOC', hand_side: 'left' },
      exemplary_image_of: [{ ark_id: @digital_object.ark_id }, { ark_id: @collection.ark_id, _destroy: 1 } ]

    }
    VCR.use_cassette('services/filestreams/file_set/update', record: :new_episodes) do
      @success, @result = described_class.call(@collection, json_data: @update_attributes)
    end
  end
end
