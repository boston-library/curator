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
    def collection_as_json(collection, opts = {})
      collection.as_json(opts).each(&:compact!)
    end
  end

  module FactoryHandler
    def handle_factory_result(factory_class, json_data = {})
      success, result = factory_class.call(json_data: json_data)
      return success, result if success

      raise result.class, result.record if result.kind_of?(ActiveRecord::RecordInvalid)

      raise result.class, result.message if result.kind_of?(Exception)

      raise ActiveRecord::RecordInvalid, result
    end
  end
end

RSpec.configure do |config|
  config.include FactoryHelpers::FactoryFor, type: :model
  config.include FactoryHelpers::CollectionAsJson, type: :service
  config.include FactoryHelpers::FactoryHandler, type: :service
end
