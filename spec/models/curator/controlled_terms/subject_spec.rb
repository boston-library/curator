# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/canonicable'
require_relative '../shared/controlled_terms/reindex_descriptable'
require_relative '../shared/mappings/mapped_terms'

RSpec.describe Curator::ControlledTerms::Subject, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  it_behaves_like 'canonicable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('lcsh') }
    let!(:term_data) { { id_from_auth: 'sh2018001243' } }

    before(:each) { VCR.insert_cassette('controlled_terms/subject_canonicable', allow_playback_repeats: true) }

    after(:each) { VCR.eject_cassette }
    # rubocop:enable RSpec/LetSetup
  end

  describe 'attr_json attributes' do
    describe 'Validations' do
      it { is_expected.to validate_presence_of(:label) }
    end
  end

  describe 'Associations' do
    it_behaves_like 'mapped_term'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:subjects).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }
  end

  describe 'Callbacks' do
    it_behaves_like 'reindex_descriptable' do
      let(:test_term) do
        create(:curator_metastreams_descriptive, subject_count: 1).reload.subject_topics.first
      end
    end
  end
end
