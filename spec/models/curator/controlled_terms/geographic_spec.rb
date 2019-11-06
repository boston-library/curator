# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/cannonicable'
require_relative '../shared/mappings/mappable'

RSpec.describe Curator::ControlledTerms::Geographic, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'
  # TODO: Currently the only compatible models stubbed out are the ones loaded from the seeds(authority, genre). Look at the JSON fixtures and see if there's a way to stub the other nomenclatures that will be compatible.
  # it_behaves_like 'cannonicable'
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
    it_behaves_like 'mappable'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:geographics).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }

    it { is_expected.to have_many(:institution_locations).
                        inverse_of(:location).
                        class_name('Curator::Institution').
                        with_foreign_key(:location_id).
                        dependent(:nullify) }
  end
end
