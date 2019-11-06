# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/cannonicable'
require_relative '../shared/mappings/mappable'

RSpec.describe Curator::ControlledTerms::Name, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  describe 'attr_json attributes' do
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to respond_to(:affiliation) }
    it { is_expected.to respond_to(:name_type) }

    it 'expects the attributes to have specific types' do
      expect(described_class.attr_json_registry.fetch(:affiliation, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
      expect(described_class.attr_json_registry.fetch(:name_type, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
    end
  end

  describe 'Associations' do
    it_behaves_like 'mappable'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:names).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }

    it { is_expected.to have_many(:desc_name_roles).
                        inverse_of(:name).
                        class_name('Curator::Mappings::DescNameRole').
                        with_foreign_key(:name_id).
                        dependent(:destroy) }

    it { is_expected.to have_many(:physical_locations_of).
                        inverse_of(:physical_location).
                        class_name('Curator::Metastreams::Descriptive').
                        with_foreign_key(:physical_location_id).
                        dependent(:destroy) }
  end
end
