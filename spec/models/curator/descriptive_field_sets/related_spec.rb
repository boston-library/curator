# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/descriptive_field_sets/field_set_base'
RSpec.describe Curator::DescriptiveFieldSets::Related, type: :model do
  subject { create(:curator_descriptives_related) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    it { is_expected.to respond_to(:constituent, :other_format, :referenced_by_url, :references_url, :review_url) }

    describe 'attr_json settings' do
      let(:array_string_fields) { %i(other_format referenced_by_url references_url review_url) }
      let(:array_string_types) { array_string_fields.map { |str_type| described_class.attr_json_registry.fetch(str_type, nil)&.type } }

      it 'expects the attributes to have the following types' do
        expect(described_class.attr_json_registry.fetch(:constituent, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
        array_string_types.each do |str_type|
          expect(str_type).to be_a_kind_of(AttrJson::Type::Array)
          expect(str_type&.base_type).to be_a_kind_of(ActiveModel::Type::String)
        end
      end

      it 'expects the attributes to have types that match values' do
        expect(subject.constituent).to be_an_instance_of(String)
        array_string_fields.each do |str_type|
          expect(subject.public_send(str_type)).to be_a_kind_of(Array).and all(be_an_instance_of(String))
        end
      end
    end
  end
end
