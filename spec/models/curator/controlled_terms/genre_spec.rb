# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/canonicable'
require_relative '../shared/controlled_terms/id_from_auth_unique_validatable'
require_relative '../shared/controlled_terms/id_from_auth_findable'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/mappings/mapped_terms'

RSpec.describe Curator::ControlledTerms::Genre, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  it_behaves_like 'id_from_auth_findable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('gmgpc') }
    let!(:id_from_auth) { 'tgm008084' }
    let!(:term_data) { { id_from_auth: id_from_auth } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/id_from_auth_findable_genre', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  it_behaves_like 'id_from_auth_uniqueness_validatable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('gmgpc') }
    let!(:term_data) { { id_from_auth: 'tgm008084' } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/id_from_auth_uniqueness_validatable_genre', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  it_behaves_like 'canonicable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('gmgpc') }
    let!(:term_data) { { id_from_auth: 'tgm008084' } }

    before(:each) { VCR.insert_cassette('services/controlled_terms/genre_canonicable', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  describe 'attr_json attributes' do
    it { is_expected.to respond_to(:basic) }
    it { is_expected.to have_db_index("(((term_data ->> 'basic'::text))::boolean)") }

    it 'expects the attributes to have specific types' do
      expect(described_class.attr_json_registry.fetch(:basic, nil)&.type).to be_a_kind_of(ActiveModel::Type::Boolean)
    end

    it 'expects the genre attribute to default to false' do
      expect(subject.basic).to be_falsey
    end

    describe 'Validations' do
      it { is_expected.to validate_presence_of(:label) }
    end
  end

  describe 'scopes' do
    it 'expects there to be a basic scope' do
      expect(described_class).to respond_to(:basic_genres)
      expect(described_class.basic_genres.to_sql).to eq(described_class.jsonb_contains(basic: true).to_sql)
    end

    it 'expects there to be a specific scope' do
      expect(described_class).to respond_to(:specific_genres)
      expect(described_class.specific_genres.to_sql).to eq(described_class.jsonb_contains(basic: false).to_sql)
    end
  end

  describe 'Associations' do
    it_behaves_like 'mapped_term'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:genres).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }
  end

  describe 'Callbacks' do
    it_behaves_like 'reindex_descriptable' do
      let(:test_term) do
        create(:curator_metastreams_descriptive, genre_count: 1).reload.genres.first
      end
    end
  end
end
