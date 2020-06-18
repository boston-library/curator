# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::CollectionUpdaterService, type: :service do
  before(:all) do
    @collection ||= create(:curator_collection)
    @digital_object ||= create(:curator_digital_object, admin_set: @collection)
    @old_image_file_set ||= create(:curator_filestreams_image, file_set_of: @digital_object)
    @new_image_file_set ||= create(:curator_filestreams_image, file_set_of: @digital_object)

    create(:curator_mappings_exemplary_image, exemplary_object: @collection, exemplary_file_set: @old_image_file_set)

    @update_attributes ||= {
      abstract: "#{@collection.abstract} [UPDATED]",
      exemplary_file_set: {
        ark_id: @new_image_file_set.ark_id
      }
    }
    VCR.use_cassette('services/collections/update', record: :new_episodes) do
      @success, @result = described_class.call(@collection, json_data: @update_attributes)
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      specify { expect(subject).to be_valid }
      specify { expect(subject.ark_id).to eq(@collection.ark_id) }

      it 'expects the attributes to have been updated' do
        [:abstract].each do |attr|
          expect(subject.public_send(attr)).to eq(@update_attributes[attr])
        end
      end

      it 'expects the #exemplary_file_set to have been replaced' do
        expect(subject.exemplary_file_set).to be_valid
        expect(subject.exemplary_file_set.ark_id).not_to eq(@old_image_file_set.ark_id)
        expect(subject.exemplary_file_set.ark_id).to eq(@new_image_file_set.ark_id)
      end
    end
  end
end
