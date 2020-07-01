# frozen_string_literal: true

module Curator
  class MetastreamDecorator < Decorators::BaseDecorator
    def administrative
      return @administrative if defined?(@administrative)

      @administrative = __getobj__.administrative if __getobj__.respond_to?(:administrative)
    end

    def descriptive
      return @descriptive if defined?(@descriptive)

      @administrative = __getobj__.descriptive if __getobj__.respond_to?(:descriptive)
    end

    def workflow
      return @workflow if defined?(@workflow)

      @workflow = __getobj__.administrative if __getobj__.respond_to?(:administrative)
    end

    def blank?
      return true if __getobj__.blank?

      administrative.blank? && descriptive.blank? && workflow.blank?
    end
  end
end
