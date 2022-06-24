# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::LanguageOfCatalogingModsPresenter
    # This class is for serializing <mods:recordInfo><mods:LanguageOfCataloging> elements/attributes
    DEFAULT_LANG_TERM_ATTRS = {
      label: 'eng',
      type: 'code',
      authority: 'iso639-2b',
      authority_uri: 'http://id.loc.gov/vocabulary/iso639-2',
      value_uri: 'http://id.loc.gov/vocabulary/iso639-2/eng'
    }.freeze
    ## Subclass LanguageTerm[Struct]
    ## This Struct is for serializing <mods:recordInfo><mods:LanguageOfCataloging><mods:languageTerm> elements/attributes
    ## LanguageTerm#initialize
    ## @param :label [String]
    ## @param :type [String]
    ## @param :authority [String]
    ## @param :authority_uri [String]
    ## @param :value_uri [String]
    ## @returns [Struct:Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter::LanguageTerm] instance
    LanguageTerm = Struct.new(:label, :type, :authority, :authority_uri, :value_uri, keyword_init: true)

    attr_reader :language_term
    # @param[optional] language_term_attrs [Hash[defaults to DEFAULT_LANG_TERM_ATTRS]]
    # @returns [Curator::DescriptiveFieldSets::LanguageOfCatalogingModsPresenter]
    def initialize(language_term_attrs = DEFAULT_LANG_TERM_ATTRS)
      @language_term = LanguageTerm.new(**language_term_attrs)
    end
  end
end
