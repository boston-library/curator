# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable'
require_relative '../shared/timestampable'

RSpec.describe Curator::ControlledTerms::Authority, type: :model do
  subject { create(:curator_controlled_terms_authority) }

  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'

  it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:code).of_type(:string) }
  it { is_expected.to have_db_column(:base_url).of_type(:string) }

  it { is_expected.to have_db_index(:code).unique(true) }
  it { is_expected.to have_db_index([:code, :base_url]).unique(true) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_uniqueness_of(:code).allow_nil }
  it { is_expected.to validate_uniqueness_of(:base_url).scoped_to(:code).allow_nil }

  it { is_expected.to allow_values(nil, 'http://myinstitution.org').for(:base_url) }
  it { is_expected.not_to allow_value('not a website string').for(:base_url) }

  describe 'cannonical authority' do
    describe 'AUTH_NAME_KEY private constant' do
      it 'expects AUTH_NAME_KEY to have the proper value set' do
        expect(described_class.const_get(:AUTH_NAME_KEY)).to be('http://www.w3.org/2000/01/rdf-schema#label')
      end
    end

    describe '.cannonical_json_format' do
      let(:skos_auth) { described_class.find_by(code: 'lcsh') }
      let(:jsonld_auth) { described_class.find_by(code: 'aat') }

      it 'expects the correct response from authority instance' do
        expect(subject.cannonical_json_format).to be_nil
        expect(skos_auth.cannonical_json_format).to be('.skos.json')
        expect(jsonld_auth.cannonical_json_format).to be('.jsonld')
      end
    end

    describe '#fetch_canonical_name' do
      let!(:authority) { described_class.find_by(code: 'lcsh') }

      it 'expects #fetch_canonical_name to be called on :before_validate' do
        expect(authority.name).to be_a_kind_of(String)
        authority.name = nil
        expect(authority.send(:should_fetch_cannonical_name?)).to be_truthy
        VCR.use_cassette('controlled_terms/authority_cannonicable') do
          expect { authority.valid? }.to change(authority, :name).
          from(nil).
          to(be_a_kind_of(String))
        end
      end
    end
  end

  describe 'Associations' do
    let(:assoc_options) do
      {
        inverse_of: :authority,
        dependent: :destroy,
        foreign_key: :authority_id
      }
    end

    it { is_expected.to have_many(:genres).
        inverse_of(assoc_options[:inverse_of]).
        class_name('Curator::ControlledTerms::Genre').
        with_foreign_key(assoc_options[:foreign_key]).
        dependent(assoc_options[:dependent]) }

    it { is_expected.to have_many(:geographics).
        inverse_of(assoc_options[:inverse_of]).
        class_name('Curator::ControlledTerms::Geographic').
        with_foreign_key(assoc_options[:foreign_key]).
        dependent(assoc_options[:dependent]) }

    it { is_expected.to have_many(:languages).
        inverse_of(assoc_options[:inverse_of]).
        class_name('Curator::ControlledTerms::Language').
        with_foreign_key(assoc_options[:foreign_key]).
        dependent(assoc_options[:dependent]) }

    it { is_expected.to have_many(:licenses).
        inverse_of(assoc_options[:inverse_of]).
        class_name('Curator::ControlledTerms::License').
        with_foreign_key(assoc_options[:foreign_key]).
        dependent(assoc_options[:dependent]) }

    it { is_expected.to have_many(:names).
        inverse_of(assoc_options[:inverse_of]).
        class_name('Curator::ControlledTerms::Name').
        with_foreign_key(assoc_options[:foreign_key]).
        dependent(assoc_options[:dependent]) }

    it { is_expected.to have_many(:resource_types).
        inverse_of(assoc_options[:inverse_of]).
        class_name('Curator::ControlledTerms::ResourceType').
        with_foreign_key(assoc_options[:foreign_key]).
        dependent(assoc_options[:dependent]) }

    it { is_expected.to have_many(:roles).
        inverse_of(assoc_options[:inverse_of]).
        class_name('Curator::ControlledTerms::Role').
        with_foreign_key(assoc_options[:foreign_key]).
        dependent(assoc_options[:dependent]) }

    it { is_expected.to have_many(:subjects).
        inverse_of(assoc_options[:inverse_of]).
        class_name('Curator::ControlledTerms::Subject').
        with_foreign_key(assoc_options[:foreign_key]).
        dependent(assoc_options[:dependent]) }
  end
end
