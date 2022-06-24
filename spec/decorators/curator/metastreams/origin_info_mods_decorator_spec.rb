# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::Metastreams::OriginInfoModsDecorator, type: :decorators do
  let!(:desc_term_counts) { 2 }
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(descriptive) }
    end
  end

  describe 'Decorator Specific Behavior' do
    subject { described_class.new(descriptive) }

    let!(:expected_blank_condition) { subject.event_type.blank? && subject.publisher.blank? && subject.publication.blank? && subject.place.blank? && subject.date.blank? }

    it { is_expected.to respond_to(:publication, :event_type, :edition, :publisher, :date, :place, :dates_inferred?, :date_created, :date_issued, :copyright_date, :issuance, :key_date_for).with(0).arguments }
    it { is_expected.to respond_to(:is_key_date?).with(1).argument }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    it 'expects #place to return an instance of Curator::Metastreams::PlaceModsPresenter' do
      expect(subject.place).to be_truthy.and be_an_instance_of(Curator::Metastreams::PlaceModsPresenter)
    end

    it 'expects #date_created to return an Array of Curator::DescriptiveFieldSets::DateModsPresenter(s)' do
      expect(subject.date_created).to be_truthy.and be_a_kind_of(Array)
      expect(subject.date_created).not_to be_empty
      expect(subject.date_created).to include(an_instance_of(Curator::DescriptiveFieldSets::DateModsPresenter)).at_most(2).times
    end

    it 'expects #date_issued to return an Array of Curator::DescriptiveFieldSets::DateModsPresenter(s)' do
      expect(subject.date_issued).to be_truthy.and be_a_kind_of(Array)
      expect(subject.date_issued).not_to be_empty
      expect(subject.date_issued).to include(an_instance_of(Curator::DescriptiveFieldSets::DateModsPresenter)).at_most(2).times
    end

    it 'expects #copyright_date to return an Array of Curator::DescriptiveFieldSets::DateModsPresenter(s)' do
      expect(subject.copyright_date).to be_truthy.and be_a_kind_of(Array)
      expect(subject.copyright_date).not_to be_empty
      expect(subject.copyright_date).to include(an_instance_of(Curator::DescriptiveFieldSets::DateModsPresenter)).at_most(2).times
    end
  end
end
