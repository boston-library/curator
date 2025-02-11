# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'
require_relative '../shared/versionable'

RSpec.describe Curator::Metastreams::Administrative, type: :model do
  subject { build(:curator_metastreams_administrative) }

  describe 'Database' do
    it_behaves_like 'optimistic_lockable'
    it_behaves_like 'timestampable'

    it { is_expected.to have_db_column(:administratable_type).
                        of_type(:string).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:administratable_id).
                        of_type(:integer).
                        with_options(null: false) }

    it { is_expected.to have_db_column(:description_standard).
                        of_type(:integer)}

    it { is_expected.to have_db_column(:hosting_status).
                        of_type(:integer).
                        with_options(default: 'hosted') }

    it { is_expected.to have_db_column(:harvestable).
                        of_type(:boolean).
                        with_options(default: true) }

    it { is_expected.to have_db_column(:flagged).
                        of_type(:string) }

    it { is_expected.to have_db_column(:destination_site).
                        of_type(:string).
                        with_options(default: ['commonwealth']) }

    it { is_expected.to have_db_column(:oai_header_id).
                        of_type(:string) }

    it { is_expected.to have_db_index([:administratable_type, :administratable_id]).unique(true) }
    it { is_expected.to have_db_index(:description_standard) }
    it { is_expected.to have_db_index(:hosting_status) }
    it { is_expected.to have_db_index(:destination_site) }
    it { is_expected.to have_db_index(:harvestable) }
    it { is_expected.to have_db_index(:oai_header_id).unique(true) }

    it { is_expected.to define_enum_for(:description_standard).
                        with_values(aacr: 0, cco: 1, dacs: 2, gihc: 3, local: 4, rda: 5, dcrmg: 6, amremm: 7, dcrmb: 8, dcrmc: 9, dcrmmss: 10, appm: 11, dcrmm: 12, dcrb: 13).
                        backed_by_column_of_type(:integer) }

    it { is_expected.to define_enum_for(:hosting_status).
                        with_values(hosted: 0, harvested: 1).
                        backed_by_column_of_type(:integer) }
  end

  describe 'Class' do
    subject { described_class }

    it { is_expected.to be_const_defined(:VALID_DESTINATION_SITES) }
    it { is_expected.to be_const_defined(:VALID_FLAGGED_VALUES) }

    it 'expects the constants to be arrays of strings and frozen' do
      expect(subject.const_get(:VALID_DESTINATION_SITES)).to be_an_instance_of(Array).and all(be_an_instance_of(String)).and be_frozen
      expect(subject.const_get(:VALID_FLAGGED_VALUES)).to be_an_instance_of(Array).and all(be_an_instance_of(String)).and be_frozen
    end

    describe 'Scopes' do
      describe '.local_id_finder' do
        let(:oai_header_id) { 'oai:some:value' }
        let(:expected_sql) { described_class.where.not(oai_header_id: nil).where(oai_header_id: oai_header_id).to_sql }

        it 'is expected to match the expected sql' do
          expect(described_class.local_id_finder(oai_header_id).to_sql).to eql(expected_sql)
        end
      end
    end
  end

  describe 'Instance Methods' do
    it { is_expected.to respond_to(:oai_object?) }
  end

  describe 'Validations' do
    it { is_expected.to validate_uniqueness_of(:administratable_id).
                        scoped_to(:administratable_type) }

    it { is_expected.to allow_values(*(Curator::Metastreams.valid_base_types + Curator::Metastreams.valid_filestream_types)).for(:administratable_type) }
    it { is_expected.to allow_values(*(Curator::Metastreams::Administrative::VALID_FLAGGED_VALUES)).for(:flagged) }

    it 'is expected to allow :VALID_DESTINATION_SITES values' do
      expect(subject).to allow_values(*(Curator::Metastreams::Administrative::VALID_DESTINATION_SITES.each_slice(2).map { |el| el })).for(:destination_site)
    end
  end

  describe 'Default attributes' do
    let!(:default_admin) { build(:curator_metastreams_administrative) }

    it 'is expected to have the following defaults set' do
      expect(default_admin.harvestable).to be(true)
      expect(default_admin.destination_site).to be_a_kind_of(Array).and include('commonwealth')
      expect(default_admin.hosting_status).to eq('hosted')
    end
  end

  describe 'Associations' do
    it { is_expected.to belong_to(:administratable).
                        inverse_of(:administrative).
                        required }
  end

  it_behaves_like 'versionable'
end
