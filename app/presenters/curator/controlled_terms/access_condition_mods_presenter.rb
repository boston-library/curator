# frozen_string_literal: true

module Curator
  class ControlledTerms::AccessConditionModsPresenter
    # DESCRIPTION: this class is for wapping string fields on the Curator::Metastreams::Descriptive to serialize/display them as <mods:accessCondition> elements

    # @param access_condition_attrs [Array[Hash]]
    # @return [Array[Curator::ControlledTerms::AccessConditionModsPresenter]]
    def self.wrap_multiple(access_condition_attrs = [])
      access_condition_attrs.map(&method(:new))
    end

    attr_reader :rights, :access_restrictions

    def initialize(rights: nil, access_restrictions: nil)
      @rights = rights
      @access_restrictions = access_restrictions
    end

    def label
      return if blank?

      rights || access_restrictions
    end

    def display_label
      return if blank? || access_restrictions.present?

      'rights'
    end

    def type
      return if blank?

      return 'restriction on access' if access_restrictions.present?

      ControlledTerms::ACCESS_CONDITION_TYPE
    end

    def blank?
      rights.blank? && access_restrictions.blank?
    end
  end
end
