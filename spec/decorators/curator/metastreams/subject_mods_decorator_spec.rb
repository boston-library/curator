# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::Metastreams::SubjectModsDecorator, type: :decorators do
  let!(:desc_term_counts) { 2 }
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }
  let!(:desc_subjects) { descriptive.subject.to_a }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(desc_subjects.sample) }
    end

    it_behaves_like 'curator_multi_decorator' do
      let(:wrapped) { described_class.wrap_multiple(desc_subjects) }
    end
  end

  describe 'included Curator::ControlledTerms::NamePartableMods' do
    let!(:desc_subject_names) { desc_subjects.select { |sub| sub.is_a?(Curator::ControlledTerms::Name) } }

    it_behaves_like 'name_partable' do
      let(:name_partable_decorator_inst) { described_class.new(desc_subject_names.sample) }
    end
  end

  describe 'Decorator Specific Behavior' do
    subject { described_class.new(desc_subjects.sample) }

    let!(:expected_blank_condition) { subject.name.blank? && subject.topic.blank? && subject.geographic.blank? && subject.cartographic.blank? && subject.other.blank? && subject.temporal_subjects.blank? && subject.title_info.blank? }

    it { is_expected.to respond_to(:name, :geographic, :topic, :title_info, :cartographic, :temporal_subjects, :other, :geographic_subject, :cartographic_subject, :name_subject, :topic_label, :geographic_label, :geographic_display_label, :authority_code, :authority_base_url, :value_uri, :name_type, :hierarchical_geographic).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end
  end
end
