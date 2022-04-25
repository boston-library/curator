# frozen_string_literal: true

module Curator
  class Metastreams::LocationModsDecorator < Decorators::BaseDecorator

    def digital_object
      super if __getobj__.respond_to?(:digital_object)
    end

    def physical_location
      super if __getobj__.respond_to?(:physical_location)
    end

    def physical_location_name
      return if physical_location.blank?

      physical_location.label
    end

    def physical_location_department
      super if __getobj__.respond_to?(:physical_location_department)
    end

    def physical_location_shelf_locator
      super if __getobj__.respond_to?(:physical_location_shelf_locator)
    end

    def holding_simple
      return if physical_location_department.blank? && physical_location_shelf_locator.blank?

      Curator::Metastreams::HoldingSimpleModsPresenter.new(sub_location: physical_location_department, shelf_locator: physical_location_shelf_locator)
    end

    def identifiers
      __getobj__.identifier if __getobj__.respond_to?(:identifier)
    end

    def blank?
      return true if __getobj__.blank?

      digital_object.blank? && physical_location.blank? && identifiers.blank? && holding_simple.blank?
    end
  end
end
