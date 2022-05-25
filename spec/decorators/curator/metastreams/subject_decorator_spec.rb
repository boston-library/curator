# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::Metastreams::SubjectDecorator, type: :decorators do
  let!(:desc_term_counts) { 2 }
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(descriptive) }
    end
  end

  describe 'Decorator instance' do
    subject { described_class.new(descriptive) }

    let(:expected_blank_condition) { subject.topics.blank? && subject.names.blank? && subject.titles.blank? && subject.other.blank? }

    it { is_expected.to respond_to(:topics, :names, :geos, :other, :titles, :temporals, :dates, :temporal_mods, :to_a).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end
  end
end
