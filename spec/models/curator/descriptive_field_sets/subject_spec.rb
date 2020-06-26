# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/descriptive_field_sets/field_set_base'
RSpec.describe Curator::DescriptiveFieldSets::Subject, type: :model do
  subject { create(:curator_descriptives_subject) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    it { is_expected.to respond_to(:titles, :temporals, :dates) }

    describe 'attr_json settings' do
      let(:titles_attr_type) { described_class.attr_json_registry.fetch(:titles, nil)&.type }
      let(:titles_attr_model) { titles_attr_type&.base_type&.model }
      let(:temporals_attr_type) { described_class.attr_json_registry.fetch(:temporals, nil)&.type }
      let(:dates_attr_type) { described_class.attr_json_registry.fetch(:dates, nil)&.type }

      it 'expects the attributes to have the following types' do # rubocop:todo RSpec/MultipleExpectations
        expect(titles_attr_type).to be_a_kind_of(AttrJson::Type::Array)
        expect(titles_attr_model).to be(Curator::DescriptiveFieldSets::Title)
        expect(temporals_attr_type).to be_a_kind_of(AttrJson::Type::Array)
        expect(temporals_attr_type&.base_type).to be_a_kind_of(ActiveModel::Type::String)
        expect(dates_attr_type).to be_a_kind_of(AttrJson::Type::Array)
        expect(dates_attr_type&.base_type).to be_a_kind_of(ActiveModel::Type::String)
      end

      it 'expects the attributes to have types that match values' do
        expect(subject.titles).to be_a_kind_of(Array).and all(be_an_instance_of(Curator::DescriptiveFieldSets::Title))
        expect(subject.temporals).to be_a_kind_of(Array).and all(be_an_instance_of(String))
        expect(subject.dates).to be_a_kind_of(Array).and all(be_an_instance_of(String))
      end
    end
  end
end
