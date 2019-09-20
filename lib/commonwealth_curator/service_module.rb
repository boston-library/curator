# frozen_string_literal: true
module CommonwealthCurator
  module CallableService
    extend ActiveSupport::Concern

    class_methods do
      def call(*args, &block)
        new(*args).call(&block)
      end
    end
  end
  class Service
    include CallableService

    def call(&block)
      fail NotImplementedError, "#{self.class}#call is unimplemented."
    end
  end
end
