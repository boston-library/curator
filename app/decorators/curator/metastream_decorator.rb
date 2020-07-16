# frozen_string_literal: true

module Curator
  class MetastreamDecorator < Decorators::BaseDecorator
    def descriptive
      __getobj__.descriptive if __getobj__.respond_to?(:descriptive)
    end

    def blank?
      return true if __getobj__.blank?

      __getobj__&.administrative.blank? && __getobj__&.descriptive.blank? && __getobj__&.workflow.blank?
    end
  end
end
