# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::DescriptiveFieldSets::IdentifierModsDecorator, type: :decorators do
  let!(:desc_term_counts) { 3 }
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(descriptive) }
    end
  end

  describe 'Decorator Specific Behavior' do
    subject { described_class.new(descriptive) }

    let!(:expected_blank_condition) { subject.digital_object.blank? && subject.identifiers.blank? }

    it { is_expected.to respond_to(:digital_object, :identifiers, :ark_identifier, :has_uri_identifier?, :filtered_identifiers, :to_a).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    describe '#to_a' do
      let(:expected_decorator_array) { subject.has_uri_identifier? ? Array.wrap(subject.filtered_identifiers) : Array.wrap(subject.ark_identifier) + Array.wrap(subject.filtered_identifiers) }

      it 'is expected to return an array of Curator::DescriptiveFieldSets::Identifier' do
        expect(subject.to_a).to be_an_instance_of(Array)
        expect(subject.to_a).not_to be_empty
        expect(subject.to_a).to all(be_an_instance_of(Curator::DescriptiveFieldSets::Identifier))
      end

      it 'is expected to match the :expected_decorator_array' do
        expect(subject.to_a).to match_array(expected_decorator_array)
      end
    end
  end
end
