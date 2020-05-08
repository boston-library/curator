# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/canonicable'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/mappings/mapped_terms'

RSpec.describe Curator::ControlledTerms::Geographic, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'
  it_behaves_like 'canonicable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('tgn') }
    let!(:term_data) { { id_from_auth: '7004939' } }

    before(:each) { VCR.insert_cassette('controlled_terms/geographic_canonicable', allow_playback_repeats: true) }

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
