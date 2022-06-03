# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::DescriptiveFieldSets::RelatedModsDecorator, type: :decorators do
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: 2) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(descriptive) }
    end
  end

  describe 'Decorator Specific Behavior' do
    subject { described_class.new(descriptive) }

    let!(:expected_blank_condition) { subject.related.blank? && subject.related_hosts.blank? && subject.related_series.blank? }
    let!(:expected_host_collection_names) { descriptive.host_collections.names }

    it { is_expected.to respond_to(:related, :related_series, :related_hosts, :related_constituent, :related_referenced_by, :related_references, :related_review_of, :related_other_format, :host_collection_names, :to_a).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    it 'expects #related to return the same Curator::DescriptiveFieldSets::Related instance as the :descriptive' do
      expect(subject.related).to be_truthy.and be_an_instance_of(Curator::DescriptiveFieldSets::Related)
      expect(subject.related).to equal(descriptive.related)
    end

    it 'expects #host_collection_names to match the :expected_host_collection_names' do
      expect(subject.host_collection_names).to be_truthy.and be_a_kind_of(Array)
      expect(subject.host_collection_names).not_to be_empty
      expect(subject.host_collection_names).to match_array(expected_host_collection_names)
    end

    it 'expects #related_series to return a Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter' do
      expect(subject.related_series).to be_truthy.and be_an_instance_of(Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter)
    end

    it 'expects #related_constituent to return an instance of Curator::DescriptiveFieldSets::RelatedItemModsPresenter' do
      expect(subject.related_constituent).to be_truthy.and be_an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter)
    end

    it 'expects #related_hosts to return an Array of Curator::DescriptiveFieldSets::RelatedItemModsPresenter(s)' do
      expect(subject.related_hosts).to be_a_kind_of(Array)
      expect(subject.related_hosts).not_to be_empty
      expect(subject.related_hosts).to all(be_an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter))
    end

    it 'expects #related_referenced_by to return an Array of Curator::DescriptiveFieldSets::RelatedItemModsPresenter(s)' do
      expect(subject.related_referenced_by).to be_a_kind_of(Array)
      expect(subject.related_referenced_by).not_to be_empty
      expect(subject.related_referenced_by).to all(be_an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter))
    end

    it 'expects #related_references to return an Array of Curator::DescriptiveFieldSets::RelatedItemModsPresenter(s)' do
      expect(subject.related_references).to be_a_kind_of(Array)
      expect(subject.related_references).not_to be_empty
      expect(subject.related_references).to all(be_an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter))
    end

    it 'expects #related_review_of to return an Array of Curator::DescriptiveFieldSets::RelatedItemModsPresenter(s)' do
      expect(subject.related_review_of).to be_a_kind_of(Array)
      expect(subject.related_review_of).not_to be_empty
      expect(subject.related_review_of).to all(be_an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter))
    end

    it 'expects #related_other_format to return an Array of Curator::DescriptiveFieldSets::RelatedItemModsPresenter(s)' do
      expect(subject.related_other_format).to be_a_kind_of(Array)
      expect(subject.related_other_format).not_to be_empty
      expect(subject.related_other_format).to all(be_an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter))
    end

    describe '#to_a' do
      let(:expected_decorator_array) do
        Array.wrap(subject.related_hosts) + Array.wrap(subject.related_series) + Array.wrap(subject.related_constituent) + Array.wrap(subject.related_references) + Array.wrap(subject.related_review_of) + Array.wrap(subject.related_referenced_by) + Array.wrap(subject.related_other_format)
      end

      it 'is expected to return an array of Curator::DescriptiveFieldSets::RelatedItemModsPresenter and Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter' do
        expect(subject.to_a).to be_a_kind_of(Array)
        expect(subject.to_a).not_to be_empty
        expect(subject.to_a).to include(an_instance_of(Curator::DescriptiveFieldSets::RelatedSeriesModsPresenter)).at_least(:once)
        expect(subject.to_a).to include(an_instance_of(Curator::DescriptiveFieldSets::RelatedItemModsPresenter)).at_least(5).times
      end

      it 'is expected to match the :expected_decorator_array' do
        expect(subject.to_a).to match_array(expected_decorator_array)
      end
    end
  end
end
