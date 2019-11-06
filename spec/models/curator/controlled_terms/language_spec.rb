# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/cannonicable'
require_relative '../shared/mappings/mappable'
RSpec.describe Curator::ControlledTerms::Language, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'
  # TODO: Currently the only compatible models stubbed out are the ones loaded from the seeds(authority, genre). Look at the JSON fixtures and see if there's a way to stub the other nomenclatures that will be compatible.
  # it_behaves_like 'cannonicable'
  describe 'attr_json attributes' do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_presence_of(:id_from_auth) }
  end

  describe 'Associations' do
    it_behaves_like 'mappable'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:languages).
                        class_name('Curator::ControlledTerms::Authority').
                        required }
  end
end
