# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/field_sets/field_set_base'
RSpec.describe Curator::FieldSets::TitleSet, type: :model do
  subject { create(:curator_descriptives_title_set) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    it { is_expected.to respond_to(:primary, :other) }

    describe 'validations' do
      it { is_expected.to validate_presence_of(:primary) }
    end

    describe 'attr_json settings' do
      let(:primary_attr_type) { described_class.attr_json_registry.fetch(:primary, nil)&.type }
      let(:other_attr_type) { described_class.attr_json_registry.fetch(:other, nil)&.type }
      let(:primary_attr_model) { primary_attr_type&.model }
      let(:other_attr_model) { other_attr_type&.base_type&.model }
      it 'expects the attributes to have the following types' do
        expect(primary_attr_type).to be_a_kind_of(AttrJson::Type::Model)
        expect(primary_attr_model).to be(Curator::FieldSets::Title)
        expect(other_attr_type).to be_a_kind_of(AttrJson::Type::Array)
        expect(other_attr_model).to be(Curator::FieldSets::Title)
      end

      it 'expects the attributes to have types that match values' do
        expect(subject.primary).to be_a_kind_of(Curator::FieldSets::Title)
        expect(subject.other).to be_a_kind_of(Array).and all(be_an_instance_of(Curator::FieldSets::Title))
      end
    end
  end
end
