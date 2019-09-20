# frozen_string_literal: true
module CommonwealthCurator
  class ApplicationService
    class << self
      def call(*args, &block)
        self.new(&args).call(&block)
      end
    end


    def call(&block)
      fail NotImplementedError, 'Abstract call cannot be called!'
    end
  end
end
