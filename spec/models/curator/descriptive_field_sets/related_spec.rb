# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/descriptive_field_sets/field_set_base'
RSpec.describe Curator::DescriptiveFieldSets::Related, type: :model do
  subject { create(:curator_descriptives_related) }

  it_behaves_like 'field_set_base'

  describe 'attributes' do
    it { is_expected.to respond_to(:constituent, :other_format, :referenced_by, :references_url, :review_url, :succeeding, :preceding).with(0).arguments }

    describe 'attr_json settings' do
      let!(:array_string_fields) { %i(other_format references_url review_url) }
      let!(:array_related_title_fields) { %i(succeeding preceding) }
      let!(:array_string_types) { array_string_fields.map { |str_type| described_class.attr_json_registry.fetch(str_type, nil)&.type } }
      let!(:array_related_title_types) { array_related_title_fields.map { |rt_type| described_class.attr_json_registry.fetch(rt_type, nil)&.type } }
      let!(:referenced_by_type) { described_class.attr_json_registry.fetch(:referenced_by, nil)&.type }

      it 'expects attr_json attributes to have correct types' do
        expect(described_class.attr_json_registry.fetch(:constituent, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
        expect(referenced_by_type).to be_a_kind_of(AttrJson::Type::Array)
        expect(referenced_by_type&.base_type&.model).to be(Curator::DescriptiveFieldSets::ReferencedBy)
      end

      it 'expects the attr_json attributes in :array_related_title_types be the correct types' do
        array_related_title_types.each do |rt_type|
          expect(rt_type).to be_a_kind_of(AttrJson::Type::Array)
          expect(rt_type&.base_type&.model).to be(Curator::DescriptiveFieldSets::RelatedTitle)
        end
      end

      it 'expects the attr_json attributes in :array_string_types to have correct types' do
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
        array_related_title_fields.each do |rt_type|
          expect(subject.public_send(rt_type)).to be_a_kind_of(Array).and all(be_an_instance_of(Curator::DescriptiveFieldSets::RelatedTitle))
        end
        expect(subject.referenced_by).to be_a_kind_of(Array).and all(be_an_instance_of(Curator::DescriptiveFieldSets::ReferencedBy))
      end
    end
  end
end
