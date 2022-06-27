# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'
require_relative '../shared/digital_objectable'

RSpec.describe Curator::Metastreams::RecordInfoModsDecorator, type: :decorators do
  let!(:desc_term_counts) { 2 }
  let!(:descriptive) { create(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: desc_term_counts) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(descriptive) }
    end
  end

  describe 'Decorator Constants' do
    subject { described_class }

    it { is_expected.to be_const_defined(:DEFAULT_MODS_RECORD_ORIGIN) }
    it { is_expected.to be_const_defined(:DEFAULT_MODS_DESC_STANDARD_AUTH) }
    it { is_expected.to be_const_defined(:HARVESTED_MODS_RECORD_ORIGIN) }

    it 'expects the constants to be specific types' do
      expect(subject.const_get(:DEFAULT_MODS_RECORD_ORIGIN)).to be_a_kind_of(String)
      expect(subject.const_get(:DEFAULT_MODS_DESC_STANDARD_AUTH)).to be_a_kind_of(String)
      expect(subject.const_get(:HARVESTED_MODS_RECORD_ORIGIN)).to be_a_kind_of(String)
    end
  end

  describe 'DigitalObjectable' do
    subject { described_class.new(descriptive) }

    it_behaves_like 'digital_objectable'
  end

  describe 'Decorator Specific Behavior' do
    subject { described_class.new(descriptive) }

    let!(:expected_blank_condition) { subject.digital_object.blank? && subject.record_creation_date.blank? && subject.record_change_date.blank? }
    let!(:expected_record_origin) { described_class.const_get(:DEFAULT_MODS_RECORD_ORIGIN) }
    let!(:expected_date_encoding) { Curator::Parsers::Constants::DATE_ENCODING }
    let!(:expected_description_standard_authority) { described_class.const_get(:DEFAULT_MODS_DESC_STANDARD_AUTH) }

    it { is_expected.to respond_to(:record_origin, :date_encoding, :record_content_source, :record_hosting_status, :record_institution_name, :record_creation_date, :record_change_date, :language_of_cataloging, :description_standard, :description_standard_authority).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    it 'expects #record_origin #date_encoding and #description_standard_authority to equal values based off certain constants' do
      expect(subject.record_origin).to eql(expected_record_origin)
      expect(subject.date_encoding).to eql(expected_date_encoding)
      expect(subject.description_standard_authority).to eql(expected_description_standard_authority)
    end

    it 'expects #language_of_cataloging to return an instance of Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter' do
      expect(subject.language_of_cataloging).to be_truthy.and be_an_instance_of(Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter)
    end
  end
end
