# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::ExemplaryImage, type: :model do
  subject { create(:curator_mappings_exemplary_image) }

  it { is_expected.to have_db_column(:exemplary_object_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:exemplary_object_type).
                      of_type(:string).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:exemplary_file_set_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:exemplary_file_set_type).
                      of_type(:string).
                      with_options(null: false) }

  it { is_expected.to have_db_index([:exemplary_file_set_type, :exemplary_file_set_id]) }
  it { is_expected.to have_db_index([:exemplary_object_type, :exemplary_object_id]) }

  it { is_expected.to have_db_index([:exemplary_file_set_id, :exemplary_file_set_type, :exemplary_object_id, :exemplary_object_type]).unique(true) }

  it { is_expected.to validate_uniqueness_of(:exemplary_file_set_id).
                      scoped_to([:exemplary_file_set_type, :exemplary_object_type, :exemplary_object_id]).
                      on(:create) }

  it { is_expected.to allow_values(*described_class.const_get(:VALID_EXEMPLARY_OBJECT_TYPES).collect { |type| "Curator::#{type}" }).
                      for(:exemplary_object_type).
                      on(:create) }

  it { is_expected.to allow_values(*described_class.const_get(:VALID_EXEMPLARY_FILE_SET_TYPES).collect { |type| "Curator::Filestreams::#{type}" }).
                      for(:exemplary_file_set_type).
                      on(:create) }


  describe 'Associations' do
    it { is_expected.to belong_to(:exemplary_object).
                        inverse_of(:exemplary_image_mappings).
                        required }

    it { is_expected.to belong_to(:exemplary_file_set).
                        inverse_of(:exemplary_image_of_mappings).
                        required }
  end
end
