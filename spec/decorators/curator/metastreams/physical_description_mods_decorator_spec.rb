# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'

RSpec.describe Curator::Metastreams::PhysicalDescriptionModsDecorator, type: :decorators do
  let!(:desc_term_counts) { 2 }
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(descriptive) }
    end
  end

  describe 'Decorator Specific Behavior' do
    subject { described_class.new(descriptive) }

    let!(:expected_blank_condition) { subject.digital_origin.blank? && subject.extent.blank? && subject.physical_description_note_list.blank? && subject.internet_media_type_list.blank? }
    let!(:expected_digital_origin) { descriptive.digital_origin.tr('_', ' ') }

    it { is_expected.to respond_to(:digital_origin, :extent, :note, :digital_object, :file_sets, :physical_description_note_list, :internet_media_type_list).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    it 'expects #digital_origin to eql the :expected_digital_origin' do
      expect(subject.digital_origin).to eql(expected_digital_origin)
    end

    it 'expects #physical_description_note_list to return an Array' do
      expect(subject.physical_description_note_list).to be_a_kind_of(Array)
    end

    it 'expects #internet_media_type_list to return a Array' do
      expect(subject.internet_media_type_list).to be_a_kind_of(Array)
    end
  end
end
