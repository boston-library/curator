# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/cannonicable'
require_relative '../shared/mappings/mappable'

RSpec.describe Curator::ControlledTerms::Subject, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  describe 'attr_json attributes' do
    it { is_expected.to validate_presence_of(:label) }
  end

  describe 'Associations' do
    it_behaves_like 'mappable'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:subjects).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }
  end
end
