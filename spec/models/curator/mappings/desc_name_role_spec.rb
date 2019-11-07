# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::DescNameRole, type: :model do
  subject { create(:curator_mappings_desc_name_role) }

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

  it { is_expected.to validate_uniqueness_of(:descriptive_id).
                      scoped_to([:name_id, :role_id]) }

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
