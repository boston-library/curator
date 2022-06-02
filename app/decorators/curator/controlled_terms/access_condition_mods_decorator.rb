# frozen_string_literal: true

module Curator
  class ControlledTerms::AccessConditionModsDecorator < Decorators::BaseDecorator
    # This class wraps and delegates classes inherited form Curator::ControlledTerms::AccessCondition to serialize/display <mods:accessCondition> elements
    # Curator::ControlledTerms::AccessConditionModsDecorator#initialize
    ## @param obj [Curator::ControlledTerms::License | Curator::ControlledTerms::RightsStatement]
    ## @return [Curator::ControlledTerms::AccessConditionModsDecorator]
    ## USAGE:
    ### NOTE: preferred usage in serializer is to use wrap_multiple method
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### access_conditions = Curator::ControlledTerms:AccessConditionModsDecorator.wrap_multiple([desc.license, desc.rights_statement])
    #
    # @param access_conditions Array[Curator::ControlledTerms::License | Curator::ControlledTerms::RightsStatement]
    # @return [Array[Curator::ControlledTerms::AccessConditionModsDecorator]]
    def self.wrap_multiple(access_conditions = [])
      access_conditions.map(&method(:new))
    end

    # @return [String] - Used to dertemine the value for <mods:accessCondition>
    def label
      super if __getobj__.respond_to?(:label)
    end

    # @return [String] -  Used to determine the uri attributes' value
    def uri
      super if __getobj__.respond_to?(:uri)
    end

    # @return [String] -  Used to determine the type attributes' value
    def type
      return if __getobj__.blank?

      case __getobj__
      when Curator::ControlledTerms::RightsStatement, Curator::ControlledTerms::License
        ControlledTerms::ACCESS_CONDITION_TYPE
      when Curator::ControlledTerms::AccessConditionModsPresenter
        __getobj__.type
      end
    end

    # @return [String] - Used to determine the displayLabel attributes' value
    def display_label
      return if __getobj__.blank?

      case __getobj__
      when Curator::ControlledTerms::RightsStatement
        'rightsstatements.org'
      when Curator::ControlledTerms::License
        'license'
      when Curator::ControlledTerms::AccessConditionModsPresenter
        __getobj__.display_label
      end
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      label.blank? && type.blank? && display_label.blank? && uri.blank?
    end
  end
end
