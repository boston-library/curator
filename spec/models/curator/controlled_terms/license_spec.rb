# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/controlled_terms/nomenclature'
# NOTE: No authority delegations/ cannnicable shared examples in this class is by design

RSpec.describe Curator::ControlledTerms::License, type: :model do
  it_behaves_like 'nomenclature'

  describe 'attr_json attributes' do
    it { is_expected.to respond_to(:uri) }

    it 'expects the attributes to have specific types' do
      expect(described_class.attr_json_registry.fetch(:uri, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
    end

    describe 'Validations' do
      it { is_expected.to validate_presence_of(:label) }
      it { is_expected.to allow_values(nil, '', 'http://something.org', 'https://somethingelse.org').for(:uri) }
      it { is_expected.not_to allow_values('not', 'a', 'blank', 'string', 'or', 'url').for(:uri) }
    end
  end

  describe 'Associations' do
    describe 'Not mappable' do
      it { is_expected.not_to respond_to(:desc_terms) }
    end

    it { is_expected.to belong_to(:authority).
                        class_name('Curator::ControlledTerms::Authority').
                        optional }

    it { is_expected.to have_many(:licensees).
                        inverse_of(:license).
                        class_name('Curator::Metastreams::Descriptive').
                        with_foreign_key(:license_id).
                        dependent(:destroy) }
  end
end
