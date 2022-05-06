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

    skip 'instance' do
    end
  end

  skip 'instance' do
  end
end
