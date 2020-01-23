# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::ExemplaryImage, type: :model do
  subject { create(:curator_mappings_exemplary_image) }

  describe 'Database' do
    it { is_expected.to have_db_column(:exemplary_object_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:exemplary_object_type).
                        of_type(:string).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:exemplary_file_set_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_index([:exemplary_file_set_id]) }
    it { is_expected.to have_db_index([:exemplary_object_type, :exemplary_object_id]).unique(true) }
    it { is_expected.to have_db_index([:exemplary_file_set_id, :exemplary_object_id, :exemplary_object_type]).unique(true) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:exemplary_object_type).scoped_to([:exemplary_object_id]).on(:create).ignoring_case_sensitivity }

    it { is_expected.to validate_uniqueness_of(:exemplary_file_set_id).
                        scoped_to([:exemplary_object_id, :exemplary_object_type]).
                        on(:create).ignoring_case_sensitivity }

    it { is_expected.to allow_values(*described_class.const_get(:VALID_EXEMPLARY_OBJECT_TYPES).collect { |type| "Curator::#{type}" }).
                        for(:exemplary_object_type).
                        on(:create) }

    describe '#exemplary_file_set_class_name_validator' do
      subject { build(:curator_mappings_exemplary_image, exemplary_object: exemplary_object) }

      let!(:exemplary_object) { create(:curator_digital_object) }
      let!(:invalid_file_set) { create(:curator_filestreams_audio) }
      let!(:image_file_set) { create(:curator_filestreams_image) }
      let!(:video_file_set) { create(:curator_filestreams_video) }
      let!(:document_file_set) { create(:curator_filestreams_document) }

      it 'expects the subject to be valid if a valid file set is used' do
        subject.exemplary_file_set = image_file_set
        expect(subject).to be_valid
        subject.exemplary_file_set = video_file_set
        expect(subject).to be_valid
        subject.exemplary_file_set = document_file_set
        expect(subject).to be_valid
        subject.exemplary_file_set = invalid_file_set
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:exemplary_object).
                        inverse_of(:exemplary_image_mapping).
                        required }

    it { is_expected.to belong_to(:exemplary_file_set).
                        inverse_of(:exemplary_image_of_mappings).
                        class_name('Curator::Filestreams::FileSet').
                        required }
  end
end
