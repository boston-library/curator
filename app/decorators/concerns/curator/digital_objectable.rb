# frozen_string_literal: true

module Curator
  module DigitalObjectable
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module InstanceMethods
      # @return [Curator::DigitalObject] - Parent digital_object
      def digital_object
        super if __getobj__.respond_to?(:digital_object)
      end

      def is_harvested?
        return false if digital_object.blank?

        digital_object.is_harvested?
      end
    end
  end
end
