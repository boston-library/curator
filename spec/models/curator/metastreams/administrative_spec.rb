# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'
require_relative '../shared/archivable'

RSpec.describe Curator::Metastreams::Administrative, type: :model do
  subject { create(:curator_metastreams_administrative) }

  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'
  it_behaves_like 'archivable'

  it { is_expected.to have_db_column(:administratable_type).
                      of_type(:string).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:administratable_id).
                      of_type(:integer).
                      with_options(null: false) }

  it { is_expected.to have_db_column(:description_standard).
                      of_type(:integer)}

  it { is_expected.to have_db_column(:harvestable).
                      of_type(:boolean).
                      with_options(default: true, null: false) }

  it { is_expected.to have_db_column(:flagged).
                      of_type(:boolean).
                      with_options(default: false, null: false) }

  it { is_expected.to have_db_column(:destination_site).
                      of_type(:string).
                      with_options(default: ['commonwealth'], null: false, array: true) }


  it { is_expected.to have_db_index([:administratable_type, :administratable_id]).unique(true) }
  it { is_expected.to have_db_index(:destination_site) }
  it { is_expected.to have_db_index(:harvestable) }

  it { is_expected.to define_enum_for(:description_standard).
                      with_values(aacr: 0, cco: 1, dacs: 2, gihc: 3, local: 4, rda: 5, dcrmg: 6, amremm: 7, dcrmb: 8, dcrmc: 9, dcrmmss: 10).
                      backed_by_column_of_type(:integer) }

  it { is_expected.to validate_uniqueness_of(:administratable_id).
                      scoped_to(:administratable_type) }

  it { is_expected.to allow_values(*(Curator::Metastreams.valid_base_types + Curator::Metastreams.valid_filestream_types)).for(:administratable_type) }

  describe 'Default attributes' do
    let!(:default_admin) { build(:curator_metastreams_administrative) }

    it 'is expected to have the following defaults set' do
      expect(default_admin.harvestable).to be(true)
      expect(default_admin.flagged).to be(false)
      expect(default_admin.destination_site).to be_a_kind_of(Array).and include('commonwealth')
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:administratable).
                        inverse_of(:administrative).
                        required }
  end

end
