# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/cannonicable'
require_relative '../shared/mappings/mappable'

RSpec.describe Curator::ControlledTerms::ResourceType, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'
  it_behaves_like 'cannonicable' do
    let!(:authority) { find_authority_by_code('resourceTypes') }
    let!(:term_data) { { id_from_auth: 'img' } }

    before(:each) do
      VCR.insert_cassette('controlled_terms/resource_type_cannonicable',
        allow_playback_repeats: true)
    end

    after(:each) do
      VCR.eject_cassette
    end
  end

  describe 'attr_json attributes' do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:id_from_auth) }
  end

  describe 'Associations' do
    it_behaves_like 'mappable'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:resource_types).
                        class_name('Curator::ControlledTerms::Authority').
                        required }
  end
end
