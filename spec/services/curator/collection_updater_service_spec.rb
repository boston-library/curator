# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::CollectionUpdaterService, type: :service do
  before(:all) do
    @collection ||= create(:curator_collection)
    @digital_object ||= create(:curator_digital_object, admin_set: @collection)
    @image_file_set ||= create(:curator_filestreams_image, file_set_of: @digital_object)
    @update_attributes ||= {
      abstract: "#{@collection.abstract} [UPDATED]",
      exemplary_file_set: {
        ark_id: @image_file_set.ark_id
      }
    }
    VCR.use_cassette('collections/update', record: :new_episodes) do
      @success, @result = described_class.call(@collection, json_data: @update_attributes)
    end
  end

  describe '#call' do
    specify { expect(@success).to be_truthy }
    describe ':result' do
      subject { @result }

      specify { expect(subject.id).to eq(@collection.id) }
      specify { expect(subject.ark_id).to eq(@collection.ark_id) }
      specify { expect(subject.admin_set_objects.pluck(:ark_id)).to include(@digital_object.ark_id) }
      specify { expect(@digital_object.file_sets.exemplaryable.pluck(:ark_id)).to include(@image_file_set.ark_id) }

      it { is_expected.to be_valid }

      it 'expects the attributes to have been updated' do
        [:abstract].each do |attr|
          expect(subject.public_send(attr)).to eq(@update_attributes[attr])
        end
      end

      it 'expects the #exemplary_file_set to have been replaced' do
        expect(subject.exemplary_file_set).to be_truthy
        expect(subject.exemplary_file_set.ark_id).to eq(@image_file_set.ark_id)
      end
    end
  end
end
