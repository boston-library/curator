# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/canonicable'
require_relative '../shared/controlled_terms/id_from_auth_unique_validatable'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/mappings/mapped_terms'
RSpec.describe Curator::ControlledTerms::Language, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  it_behaves_like 'id_from_auth_uniqueness_validatable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('iso639-2') }
    let!(:term_data) { { id_from_auth: 'bar', label: 'Bar' } } # NOTE: Using invalid data to test that validation fails as expected

    before(:each) { VCR.insert_cassette('services/controlled_terms/id_from_auth_uniqueness_validatable_language', allow_playback_repeats: true) }

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
                        inverse_of(:languages).
                        class_name('Curator::ControlledTerms::Authority').
                        required }
  end

  describe 'Callbacks' do
    it_behaves_like 'reindex_descriptable' do
      let(:test_term) do
        create(:curator_metastreams_descriptive, language_count: 1).reload.languages.first
      end
    end
  end
end
