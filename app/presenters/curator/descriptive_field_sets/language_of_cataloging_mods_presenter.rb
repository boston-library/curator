# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::LanguageOfCatalogingModsPresenter

    LanguageTerm = Struct.new(:label, :type, :authority, :authority_uri, :value_uri, keyword_init: true)

    DEFAULT_USAGE='primary'
    DEFAULT_LANG_TERM_ATTRS={
      label: 'eng',
      type: 'code',
      authority: 'iso639-2b',
      authority_uri: 'http://id.loc.gov/vocabulary/iso639-2',
      value_uri: 'http://id.loc.gov/vocabulary/iso639-2/eng'
    }.freeze

    attr_reader :language_term, :usage

    def initialize(language_term_attrs = DEFAULT_LANG_TERM_ATTRS, usage = DEFAULT_USAGE)
      @language_term = LanguageTerm.new(**language_term_attrs)
      @usage = usage
    end
  end
end
