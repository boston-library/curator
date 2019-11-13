# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::DescTerm, type: :model do
  subject { create(:curator_mappings_desc_term) }

  it { is_expected.to have_db_column(:descriptive_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:mappable_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:mappable_type).
                      of_type(:string).
                      with_options(null: false) }

  it { is_expected.to have_db_index(:descriptive_id) }
  it { is_expected.to have_db_index([:mappable_type, :mappable_id]) }

  it { is_expected.to have_db_index([:mappable_id, :mappable_type, :descriptive_id]).unique(true) }

  it { is_expected.to validate_uniqueness_of(:descriptive_id).
                      scoped_to([:mappable_id, :mappable_type]).
                      on(:create) }

  it { is_expected.to allow_values(*Curator::ControlledTerms.nomenclature_types.collect { |type| "Curator::ControlledTerms::#{type}" }).
                      for(:mappable_type).
                      on(:create) }

  describe 'Associations' do
    it { is_expected.to belong_to(:descriptive).
                        inverse_of(:desc_terms).
                        class_name('Curator::Metastreams::Descriptive').
                        with_foreign_key(:descriptive_id).
                        required }

    it { is_expected.to belong_to(:mappable).
                        inverse_of(:desc_terms).
                        required }
  end
end
