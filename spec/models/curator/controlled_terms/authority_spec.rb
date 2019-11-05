# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/optimistic_lockable.rb'
require_relative '../shared/timestampable.rb'

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

  describe '.cannonical_json_format' do

    let(:skos_auth) { Curator::ControlledTerms::Authority.find_by(code: 'lcsh') }
    let(:jsonld_auth) { Curator::ControlledTerms::Authority.find_by(code: 'aat') }

    it 'expects the correct response from authority instance' do
      expect(subject.cannonical_json_format).to be_nil
      expect(skos_auth.cannonical_json_format).to be('.skos.json')
      expect(jsonld_auth.cannonical_json_format).to be('.jsonld')
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
