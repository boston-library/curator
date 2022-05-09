# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter, type: :presenters do
  subject { described_class }

  specify { expect(subject).to be_const_defined(:DEFAULT_USAGE) }
  specify { expect(subject).to be_const_defined(:DEFAULT_LANG_TERM_ATTRS) }
  specify { expect(subject).to be_const_defined(:LanguageTerm) }

  it { is_expected.to respond_to(:new).with(0..2).arguments }

  describe Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter::LanguageTerm do
    subject { described_class }

    it { is_expected.to be <= Struct }
    it { is_expected.to respond_to(:new) }

    # NOTE: Struct initializer arguments/keywords have to be tested this(below) way and won't work with respond_to(...).with_keywords(...)

    it 'is expected to have the following member attributes' do
      expect(subject.members).to include(:label, :type, :authority, :authority_uri, :value_uri)
    end

    describe 'instance' do
      subject { described_class.new(**language_term_attrs) }

      let!(:language_term_attrs) do
        {
          label: 'eng',
          type: 'code',
          authority: 'iso639-2b',
          authority_uri: 'http://id.loc.gov/vocabulary/iso639-2',
          value_uri: 'http://id.loc.gov/vocabulary/iso639-2/eng'
        }
      end

      it { is_expected.to respond_to(*language_term_attrs.keys).with(0).arguments }

      it 'expects the instance to store the correct values' do
        language_term_attrs.each do |lang_term_attr, lang_term_val|
          expect(subject.public_send(lang_term_attr)).to eql(lang_term_val)
        end
      end
    end
  end

  describe 'instance' do
    subject { described_class.new }

    let!(:default_lang_term_attrs) { described_class.const_get(:DEFAULT_LANG_TERM_ATTRS) }
    let!(:default_usage) { described_class.const_get(:DEFAULT_USAGE) }

    it { is_expected.to respond_to(:language_term, :usage).with(0).arguments }

    it 'expects #usage to eql :DEFAULT_USAGE' do
      expect(subject.usage).to eql(default_usage)
    end

    it 'expects #language_term to be a Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter::LanguageTerm' do
      expect(subject.language_term).to be_an_instance_of(Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter::LanguageTerm)
    end

    it 'expects #language_term to have the same values as :DEFAULT_LANG_TERM_ATTRS' do
      default_lang_term_attrs.each do |def_lang_term_attr, def_lang_term_val|
        expect(subject.language_term.public_send(def_lang_term_attr)).to eql(def_lang_term_val)
      end
    end
  end
end
