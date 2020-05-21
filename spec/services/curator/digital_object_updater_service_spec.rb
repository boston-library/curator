# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DigitalObjectUpdaterService, type: :service do
  before(:all) do
    @digital_object ||= create(:curator_digital_object)
    @old_image_file_set ||= create(:curator_filestreams_image, file_set_of: @digital_object)
    create(:curator_mappings_exemplary_image, exemplary_object: @digital_object, exemplary_file_set: @old_image_file_set)

    @new_image_file_set ||= create(:curator_filestreams_image, file_set_of: @digital_object)
    @add_collection ||= create(:curator_collection, institution: @digital_object.institution)
    @remove_collection ||= create(:curator_mappings_collection_member, collection: create(:curator_collection, institution: @digital_object.institution), digital_object: @digital_object)
    @update_attributes ||= {
      collection_members: [{ ark_id: @add_collection.ark_id }, { id: @remove_collection.id, _destroy: '1' }],
      exemplary_file_set: {
        ark_id: @new_image_file_set.ark_id
      }
    }
    VCR.use_cassette('services/digital_object/update', record: :new_episodes) do
      @success, @result = described_class.call(@digital_object, json_data: @update_attributes)
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }

    describe ':result' do
      subject { @result }

      specify { expect(subject).to be_valid }
      specify { expect(subject.ark_id).to eq(@digital_object.ark_id) }

      it 'expects the #collection_members to have been updated' do
        expect(subject.collection_members.count).to eq(2)
        expect(subject.collection_members.pluck(:collection_id)).not_to include(@remove_collection.id)
        expect(subject.collection_members.pluck(:collection_id)).to include(@digital_object.admin_set_id, @add_collection.id)
      end

      it 'expects the #exemplary_file_set to have been replaced' do
        expect(subject.exemplary_file_set).to be_valid
        expect(subject.exemplary_file_set.ark_id).not_to eq(@old_image_file_set.ark_id)
        expect(subject.exemplary_file_set.ark_id).to eq(@new_image_file_set.ark_id)
      end
    end
  end
end
