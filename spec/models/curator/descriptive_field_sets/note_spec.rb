# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/descriptive_field_sets/field_set_base'
RSpec.describe Curator::DescriptiveFieldSets::Note, type: :model do
  subject { create(:curator_descriptives_note) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    it { is_expected.to respond_to(:label, :type).with(0).arguments }

    describe 'validations' do
      it { is_expected.to validate_inclusion_of(:type).
                          in_array(Curator::DescriptiveFieldSets::NOTE_TYPES) }
    end

    describe 'attr_json settings' do
      let(:field_types) { %i(label type).map { |field| described_class.attr_json_registry.fetch(field, nil)&.type } }
      it 'expects the attributes to have the following types' do
        expect(field_types).to all(be_a_kind_of(ActiveModel::Type::String))
      end

      it 'expects the attributes to have types that match values' do
        expect(subject.label).to be_an_instance_of(String)
        expect(subject.type).to be_an_instance_of(String).and satisfy { |type| Curator::DescriptiveFieldSets::NOTE_TYPES.include?(type) }
      end
    end
  end
end
