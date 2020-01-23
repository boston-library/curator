# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::DescTerm, type: :model do
  subject { create(:curator_mappings_desc_term) }

  it { is_expected.to have_db_column(:descriptive_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:mapped_term_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_index(:descriptive_id) }
  it { is_expected.to have_db_index(:mapped_term_id) }

  it { is_expected.to have_db_index([:mapped_term_id, :descriptive_id]).unique(true) }

  it { is_expected.to validate_uniqueness_of(:descriptive_id).
                      scoped_to(:mapped_term_id).
                      on(:create) }

  describe 'Associations' do
    it { is_expected.to belong_to(:descriptive).
                        inverse_of(:desc_terms).
                        class_name('Curator::Metastreams::Descriptive').
                        required }

    it { is_expected.to belong_to(:mapped_term).
                        inverse_of(:desc_terms).
                        class_name('Curator::ControlledTerms::Nomenclature').
                        required }
  end
end
