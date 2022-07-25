# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/descriptive_field_sets/field_set_base'
RSpec.describe Curator::DescriptiveFieldSets::Identifier, type: :model do
  subject { create(:curator_descriptives_identifier) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    it { is_expected.to respond_to(:label, :type, :invalid).with(0).arguments }
    it { is_expected.to respond_to(:local_original_identifier_type).with(0).arguments }

    describe 'validations' do
      it { is_expected.to validate_presence_of(:type) }
      it { is_expected.to validate_presence_of(:label) }

      it { is_expected.to validate_inclusion_of(:type).
                          in_array(Curator::DescriptiveFieldSets::IDENTIFIER_TYPES) }
    end

    describe 'attr_json settings' do
      let(:string_field_types) { %i(type label).map { |field| described_class.attr_json_registry.fetch(field, nil)&.type } }
      let(:bool_field_type) { described_class.attr_json_registry.fetch(:invalid, nil)&.type }
      it 'expects the attributes to have the following types' do
        expect(string_field_types).to all(be_a_kind_of(ActiveModel::Type::String))
        expect(bool_field_type).to be_a_kind_of(ActiveModel::Type::Boolean)
      end

      it 'expects the attributes to have types that match values' do
        expect(subject.label).to be_an_instance_of(String)
        expect(subject.type).to be_an_instance_of(String).and satisfy { |type| Curator::DescriptiveFieldSets::IDENTIFIER_TYPES.include?(type) }
        expect(subject.invalid).to be_a_kind_of(TrueClass).or be_a_kind_of(FalseClass)
      end
    end
  end
end
