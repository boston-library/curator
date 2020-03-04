# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::DescNameRole, type: :model do
  subject { build(:curator_mappings_desc_name_role) }

  describe 'Database' do
    it { is_expected.to have_db_column(:descriptive_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:name_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:role_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_index(:descriptive_id) }
    it { is_expected.to have_db_index(:name_id) }
    it { is_expected.to have_db_index(:role_id) }

    it { is_expected.to have_db_index([:descriptive_id, :name_id, :role_id]).unique(true) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:descriptive_id).
                        scoped_to([:name_id, :role_id]) }

    describe '#name_role_class_validator' do
      subject { described_class.new(descriptive: descriptive) }

      let!(:descriptive) { create(:curator_metastreams_descriptive) }
      let!(:role) { create(:curator_controlled_terms_role) }
      let!(:name) { create(:curator_controlled_terms_name) }
      let!(:neither_name_or_role) { create(:curator_controlled_terms_genre) }

      it 'expects the object to be valid if a proper #name and #role are set' do
        subject.name = name
        subject.role = role
        expect(subject).to be_valid
      end

      it 'expects the object to not be valid if any other nomencaluture class is used' do
        expect { subject.role = neither_name_or_role }.to raise_error(ActiveRecord::AssociationTypeMismatch)
        expect { subject.name = neither_name_or_role }.to raise_error(ActiveRecord::AssociationTypeMismatch)
        subject.name = name
        expect(subject).not_to be_valid
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:descriptive).
                        inverse_of(:name_roles).
                        class_name('Curator::Metastreams::Descriptive').
                        required }

    it { is_expected.to belong_to(:name).
                        inverse_of(:desc_name_roles).
                        class_name('Curator::ControlledTerms::Name').
                        required }

    it { is_expected.to belong_to(:role).
                        inverse_of(:desc_name_roles).
                        class_name('Curator::ControlledTerms::Role').
                        required }
  end
end
