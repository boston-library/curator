# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/cannonicable'
require_relative '../shared/mappings/mapped_terms'

RSpec.describe Curator::ControlledTerms::ResourceType, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'
  it_behaves_like 'cannonicable' do
    # rubocop:disable RSpec/LetSetup
    let!(:authority) { find_authority_by_code('resourceTypes') }
    let!(:term_data) { { id_from_auth: 'img' } }

    before(:each) { VCR.insert_cassette('controlled_terms/resource_type_cannonicable', allow_playback_repeats: true) }

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
                        inverse_of(:resource_types).
                        class_name('Curator::ControlledTerms::Authority').
                        required }
  end
end
