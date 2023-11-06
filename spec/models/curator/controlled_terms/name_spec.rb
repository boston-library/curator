# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/canonicable'
require_relative '../shared/controlled_terms/id_from_auth_unique_validatable'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/mappings/mapped_terms'

RSpec.describe Curator::ControlledTerms::Name, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  it_behaves_like 'id_from_auth_uniqueness_validatable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('gmgpc') }
    let!(:term_data) { { id_from_auth: 'tgm008084' } } # NOTE: Using invalid data to test that validation fails as expected

    before(:each) { VCR.insert_cassette('services/controlled_terms/id_from_auth_uniqueness_validatable_name', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  it_behaves_like 'canonicable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('naf') }
    let!(:term_data) { { id_from_auth: 'n97003077' } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/name_canonicable', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  describe 'attr_json attributes' do
    it { is_expected.to respond_to(:affiliation) }
    it { is_expected.to respond_to(:name_type) }

    describe 'Validations' do
      it { is_expected.to validate_presence_of(:label) }
      it { is_expected.to allow_values(*(Curator::ControlledTerms::Name::VALID_NAME_TYPES)).for(:name_type) }
    end

    it 'expects the attributes to have specific types' do
      expect(described_class.attr_json_registry.fetch(:affiliation, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
      expect(described_class.attr_json_registry.fetch(:name_type, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
    end
  end

  describe 'Associations' do
    it_behaves_like 'mapped_term'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:names).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }

    it { is_expected.to have_many(:desc_name_roles).
                        inverse_of(:name).
                        class_name('Curator::Mappings::DescNameRole').
                        with_foreign_key(:name_id).
                        dependent(:destroy) }

    it { is_expected.to have_many(:physical_locations_of).
                        inverse_of(:physical_location).
                        class_name('Curator::Metastreams::Descriptive').
                        with_foreign_key(:physical_location_id).
                        dependent(:destroy) }
  end

  describe 'Callbacks' do
    it_behaves_like 'reindex_descriptable' do
      let(:test_term) do
        create(:curator_metastreams_descriptive, name_role_count: 1).reload.name_roles.first.name
      end
    end
  end
end
