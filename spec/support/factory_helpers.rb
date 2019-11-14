# frozen_string_literal: true

module FactoryHelpers
  module FactoryFor
    # converts the described class constant to a underscored symbol for using the factory bot methods.
    # Useful for shared example classes
    def factory_key_for(desc_class)
      desc_class.to_s.underscore.tr!('/', '_').to_sym
    end
  end
  module CollectionAsJson
    def collection_as_json(collection, opts={})
      collection.as_json(opts).each(&:compact!)
    end
  end
end

RSpec.configure do |config|
  config.include FactoryHelpers::FactoryFor, type: :model
  config.include FactoryHelpers::CollectionAsJson, type: :service
end
