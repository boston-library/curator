# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Curator::Parsers::Constants do
  subject { described_class }

  it { is_expected.to be_const_defined(:DATE_ENCODING) }
  it { is_expected.to be_const_defined(:CORP_NAME_INPUT_MATCHER) }
  it { is_expected.to be_const_defined(:TGN_HIER_GEO_ATTRS) }
  it { is_expected.to be_const_defined(:NONSORT_ARTICLES) }
  it { is_expected.to be_const_defined(:STATE_ABBR) }

  describe ':DATE_ENCODING' do
    subject { described_class.const_get(:DATE_ENCODING) }

    it { is_expected.to be_a_kind_of(String).and eql('w3cdtf') }
  end

  describe ':CORP_NAME_INPUT_MATCHER' do
    subject { described_class.const_get(:CORP_NAME_INPUT_MATCHER) }

    it { is_expected.to be_a_kind_of(Regexp).and be_frozen }
  end

  describe ':TGN_HIER_GEO_ATTRS' do
    subject { described_class.const_get(:TGN_HIER_GEO_ATTRS) }

    it { is_expected.to be_a_kind_of(Array).and all(be_a_kind_of(Symbol)).and be_frozen }
  end

  describe ':NONSORT_ARTICLES' do
    subject { described_class.const_get(:NONSORT_ARTICLES) }

    it { is_expected.to be_a_kind_of(Array).and all(be_a_kind_of(String)).and be_frozen }
  end

  describe ':STATE_ABBR' do
    subject { described_class.const_get(:STATE_ABBR) }

    it { is_expected.to be_a_kind_of(Hash).and be_frozen }
  end
end
