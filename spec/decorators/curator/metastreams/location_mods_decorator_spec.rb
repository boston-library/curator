# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::Metastreams::LocationModsDecorator, type: :decorators do
  let!(:desc_term_counts) { 2 }
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(descriptive) }
    end
  end

  describe 'Decorator specific behavior' do
    subject { described_class.new(descriptive) }

    let!(:expected_blank_condition) { subject.digital_object.blank? && subject.physical_location.blank? && subject.identifiers.blank? && subject.holding_simple.blank? }

    it { is_expected.to respond_to(:digital_object, :physical_location, :physical_location_name, :physical_location_department, :physical_location_shelf_locator, :identifiers, :ark_identifier, :ark_preview_identifier, :ark_iiif_manifest_identifier, :ark_identifier_list, :uri_identifiers, :holding_simple, :location_uri_list, :to_a).with(0).arguments }
    it { is_expected.to respond_to(:has_ark_identifier?, :has_uri_identifier?).with(1).argument }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    describe '#to_a' do
      it 'is expected to return an array of Curator::Metastreams::LocationModsPresenter(s)' do
        expect(subject.to_a).to be_truthy.and be_a_kind_of(Array)
        expect(subject.to_a).not_to be_empty
        expect(subject.to_a).to include(an_instance_of(Curator::Metastreams::LocationModsPresenter)).at_most(2).times
      end
    end
  end
end
