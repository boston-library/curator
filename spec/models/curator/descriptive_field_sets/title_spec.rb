# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/descriptive_field_sets/field_set_base'
RSpec.describe Curator::DescriptiveFieldSets::Title, type: :model do
  subject { create(:curator_descriptives_title) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    it { is_expected.to respond_to(:label, :subtitle, :display, :display_label,
                                   :usage, :supplied, :language, :type,
                                   :authority_code, :id_from_auth, :part_number, :part_name) }

    describe 'instance methods' do
      it { is_expected.to respond_to(:non_sort, :authority, :authority_uri, :value_uri) }
    end

    describe 'attr_json settings' do
      let(:string_attributes) do
        %i(label subtitle display display_label usage language type authority_code id_from_auth part_number part_name)
      end
      it 'expects the attributes to have the following types' do
        string_attributes.each do |str_attr|
          expect(described_class.attr_json_registry.fetch(str_attr, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
        end
        expect(described_class.attr_json_registry.fetch(:supplied, nil)&.type).to be_a_kind_of(ActiveModel::Type::Boolean)
      end

      let(:title_all_values) { create(:curator_descriptives_title, :primary) }
      it 'expects the model to have the types match the values' do
        string_attributes.each do |str_attr|
          expect(title_all_values.public_send(str_attr)).to be_a_kind_of(String)
        end
        expect(title_all_values.supplied).to be_a_kind_of(TrueClass).or be_a_kind_of(FalseClass)
      end
    end
  end
end
