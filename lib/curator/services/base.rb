# frozen_string_literal: true

module Curator
  module Services
    class Base
      class << self
        def call(*args, **kwargs, &block)
          new(*args, **kwargs).call(&block)
        end
      end

      def call(&)
        raise NotImplementedError, "#{self.class}#call is unimplemented."
      end
    end
  end
end
