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
    end
  end
end
