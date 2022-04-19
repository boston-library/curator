# frozen_string_literal: true

module Curator
  class ControlledTerms::AccessConditionModsDecorator < Decorators::BaseDecorator
    ACCESS_CONDITION_TYPE='use and reproduction'

    #
    # @param access_conditions Array[Curator::ControlledTerms::AccessCondition]
    # @return Array[Curator::ControlledTerms::AccessConditionModsDecorator]
    def self.wrap_multiple(access_conditions = [])
      access_conditions.map { |ac| new(ac) }
    end

    def label
      super if __getobj__.respond_to?(:label)
    end

    def uri
      super if __getobj__.respond_to?(:uri)
    end

    def type
      return if __getobj__.blank?

      ACCESS_CONDITION_TYPE
    end

    def display_label
      return if __getobj__.blank?

      case __getobj__
      when Curator::ControlledTerms::RightsStatement
        'rights'
      when Curator::ControlledTerms::License
        'license'
      end
    end

    def blank?
      return true if __getobj__.blank?

      label.blank? && type.blank? && display_label.blank? && uri.blank?
    end
  end
end
