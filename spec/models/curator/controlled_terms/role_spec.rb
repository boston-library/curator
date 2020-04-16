# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
require_relative '../shared/controlled_terms/authority_delegation'
require_relative '../shared/controlled_terms/canonicable'
require_relative '../shared/mappings/mapped_terms'

RSpec.describe Curator::ControlledTerms::Role, type: :model do
  it_behaves_like 'nomenclature'
  it_behaves_like 'authority_delegation'

  describe 'attr_json attributes' do
    describe 'Validations' do
      it { is_expected.to validate_presence_of(:label) }
      it { is_expected.to validate_presence_of(:id_from_auth) }
    end
  end

  describe 'Associations' do
    it_behaves_like 'mapped_term'

    it { is_expected.to belong_to(:authority).
                        inverse_of(:roles).
                        class_name('Curator::ControlledTerms::Authority').
                        required }

    it { is_expected.to have_many(:desc_name_roles).
                        inverse_of(:role).
                        class_name('Curator::Mappings::DescNameRole').
                        with_foreign_key(:role_id).
                        dependent(:destroy) }
  end
end
