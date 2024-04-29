# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/canonicable'
require_relative '../shared/controlled_terms/id_from_auth_unique_validatable'
require_relative '../shared/controlled_terms/id_from_auth_findable'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/mappings/mapped_terms'

RSpec.describe Curator::ControlledTerms::Role, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  it_behaves_like 'id_from_auth_findable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('marcrelator') }
    let!(:id_from_auth) { 'bar' }
    let!(:term_data) { { id_from_auth: id_from_auth, label: 'Bar' } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/id_from_auth_findable_role', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  it_behaves_like 'id_from_auth_uniqueness_validatable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('marcrelator') }
    let!(:term_data) { { id_from_auth: 'bar', label: 'Bar' } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/id_from_auth_uniqueness_validatable_role', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  describe 'attr_json attributes' do
    describe 'Validations' do
      it { is_expected.to validate_presence_of(:label) }
      it { is_expected.to validate_presence_of(:id_from_auth) }
    end
  end

  describe 'Associations' do
    it_behaves_like 'mapped_term'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:roles).
                        class_name('Curator::ControlledTerms::Authority').
                        required }

    it { is_expected.to have_many(:desc_name_roles).
                        inverse_of(:role).
                        class_name('Curator::Mappings::DescNameRole').
                        with_foreign_key(:role_id).
                        dependent(:destroy) }
  end

  describe 'Callbacks' do
    it_behaves_like 'reindex_descriptable' do
      let(:test_term) do
        create(:curator_metastreams_descriptive, name_role_count: 1).reload.name_roles.first.role
      end
    end
  end
end
