# frozen_string_literal: true

module FactoryHelpers
  module FactoryFor
    #converts the described class constant to a underscored symbol for using the factory bot methods.
    #Useful for shared example classes
    def factory_key_for(desc_class)
      desc_class.to_s.underscore.gsub('/', '_').to_sym
    end
  end
end

RSpec.configure do |config|
  config.include FactoryHelpers::FactoryFor, type: :model
end
