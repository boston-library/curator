# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/descriptive_field_sets/field_set_base'

RSpec.describe Curator::DescriptiveFieldSets::RelatedTitle, type: :model do
  subject { create(:curator_descriptives_related_title) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    let!(:fields) { %i(label control_number) }

    it { is_expected.to respond_to(*fields).with(0).arguments }

    describe 'validations' do
      it { is_expected.to validate_presence_of(:label) }
    end

    describe 'attr_json settings' do
      let!(:field_types) { fields.map { |field| described_class.attr_json_registry.fetch(field, nil)&.type } }

      it 'expects the attributes to have the correct types' do
        expect(field_types).to all(be_a_kind_of(ActiveModel::Type::String))
      end

      it 'expects the attributes to be instances of correct types' do
        expect(subject.label).to be_an_instance_of(String)
        expect(subject.control_number).to be_an_instance_of(String)
      end
    end
  end
end
