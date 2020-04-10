# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::FileSetMember, type: :model do
  subject { build(:curator_mappings_file_set_member) }

  describe 'Database Attributes' do
    it { is_expected.to have_db_column(:digital_object_id).
         of_type(:integer).
         with_options(null: false) }

    it { is_expected.to have_db_column(:file_set_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_index(:digital_object_id) }
    it { is_expected.to have_db_index(:file_set_id) }
    it { is_expected.to have_db_index([:digital_object_id, :file_set_id]).unique(true) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:digital_object_id).
                        scoped_to(:file_set_id).
                        on(:create) }
  end

  describe 'Relationships' do
    it { is_expected.to belong_to(:digital_object).
                        inverse_of(:file_set_member_mappings).
                        class_name('Curator::DigitalObject').required }

    it { is_expected.to belong_to(:file_set).
                        inverse_of(:file_set_member_of_mappings).
                        class_name('Curator::Filestreams::FileSet').
                        required }
  end
end
