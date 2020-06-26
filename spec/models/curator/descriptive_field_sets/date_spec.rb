# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/descriptive_field_sets/field_set_base'
RSpec.describe Curator::DescriptiveFieldSets::Date, type: :model do
  subject { create(:curator_descriptives_date) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    it { is_expected.to respond_to(:created, :issued, :copyright) }

    describe 'attr_json settings' do
      let(:field_types) { %i(created issued copyright).map { |field| described_class.attr_json_registry.fetch(field, nil)&.type } }
      it 'expects the attributes to have the following types' do
        expect(field_types).to all(be_a_kind_of(ActiveModel::Type::String))
      end

      it 'expects the attributes to have types that match values' do
        expect(subject.created).to be_an_instance_of(String)
        expect(subject.issued).to be_an_instance_of(String)
        expect(subject.copyright).to be_an_instance_of(String)
      end
    end
  end
end
