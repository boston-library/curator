# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/cannonicable'
require_relative '../shared/mappings/mappable'

RSpec.describe Curator::ControlledTerms::Genre, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  it_behaves_like 'cannonicable' do
    let!(:authority) { find_authority_by_code('gmgpc') }
    let!(:term_data) { { id_from_auth: 'tgm008084' } }

    before(:each) do
      VCR.insert_cassette('controlled_terms/genre_cannonicable',
        allow_playback_repeats: true)
    end

    after(:each) do
      VCR.eject_cassette
    end
  end

  describe 'attr_json attributes' do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to have_db_index("(((term_data ->> 'basic'::text))::boolean)") }
    it { is_expected.to respond_to(:basic) }

    it 'expects the attributes to have specific types' do
      expect(described_class.attr_json_registry.fetch(:basic, nil)&.type).to be_a_kind_of(ActiveModel::Type::Boolean)
    end

    it 'expects the genre attribute to default to false' do
      expect(subject.basic).to be_falsey
    end
  end

  describe 'scopes' do
    it 'expects there to be a basic scope' do
      expect(described_class).to respond_to(:basic)
      expect(described_class.basic.to_sql).to eq(described_class.jsonb_contains(basic: true).to_sql)
    end

    it 'expects there to be a specific scope' do
      expect(described_class).to respond_to(:specific)
      expect(described_class.specific.to_sql).to eq(described_class.jsonb_contains(basic: false).to_sql)
    end
  end

  describe 'Associations' do
    it_behaves_like 'mappable'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:genres).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }
  end
end
