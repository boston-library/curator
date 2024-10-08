# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/canonicable'
require_relative '../shared/controlled_terms/id_from_auth_unique_validatable'
require_relative '../shared/controlled_terms/id_from_auth_findable'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/mappings/mapped_terms'

RSpec.describe Curator::ControlledTerms::Geographic, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  it_behaves_like 'id_from_auth_findable', test_multiple: true do
    # rubocop:disable RSpec/LetSetup
    let!(:id_from_auth) { '7004939' }
    let!(:authority) { find_authority_by_code('tgn') }
    let!(:other_authority) { find_authority_by_code('geonames') }
    let!(:term_data) { { id_from_auth: id_from_auth, label: 'Piacenza', area_type: 'city', coordinates: '45.016667,9.666667' } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/id_from_auth_findable_geographic', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  it_behaves_like 'id_from_auth_uniqueness_validatable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('tgn') }
    let!(:term_data) { { id_from_auth: '7004939', label: 'Piacenza', area_type: 'city', coordinates: '45.016667,9.666667' } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/id_from_auth_uniqueness_validatable_geographic', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  it_behaves_like 'canonicable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('tgn') }
    let!(:term_data) { { id_from_auth: '7004939' } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/geographic_canonicable', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  describe 'attr_json attributes' do
    it { is_expected.to respond_to(:area_type) }
    it { is_expected.to respond_to(:coordinates) }
    it { is_expected.to respond_to(:bounding_box) }

    it 'expects the attributes to have specific types' do
      expect(described_class.attr_json_registry.fetch(:area_type, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
      expect(described_class.attr_json_registry.fetch(:coordinates, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
      expect(described_class.attr_json_registry.fetch(:bounding_box, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
    end
  end

  describe 'Associations' do
    it_behaves_like 'mapped_term'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:geographics).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }

    it { is_expected.to have_many(:institution_locations).
                        inverse_of(:location).
                        class_name('Curator::Institution').
                        with_foreign_key(:location_id).
                        dependent(:destroy) }
  end

  describe 'Scopes' do
    describe '.tgns' do
      subject { described_class.tgns.to_sql }

      let!(:expected_sql) { described_class.with_authority.where(authority: { code: 'tgn' }).references(:authority).to_sql }

      it { is_expected.to eql(expected_sql) }
    end

    describe '.geonames' do
      subject { described_class.geonames.to_sql }

      let!(:expected_sql) { described_class.with_authority.where(authority: { code: 'geonames' }).references(:authority).to_sql }

      it { is_expected.to eql(expected_sql) }
    end
  end

  describe 'Callbacks' do
    it_behaves_like 'reindex_descriptable' do
      let(:test_term) do
        create(:curator_metastreams_descriptive, subject_count: 1).reload.subject_geos.first
      end
    end

    describe 'reindex_associated_institutions' do
      let(:location) { create(:curator_institution, :with_location).location }
      it 'runs the reindex_associated_institutions callback' do
        expect(location).to receive(:reindex_associated_institutions)
        location.save
      end
    end
  end
end
