# frozen_string_literal: true
module Curator
  module Services
    class Base
      class << self
        def call(*args, &block)
          new(*args).call(&block)
        end
      end

      def call(&block)
        fail NotImplementedError, "#{self.class}#call is unimplemented."
      end
    end
  end
end
