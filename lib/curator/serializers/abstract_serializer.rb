module Curator
  module Serializers
    class AbstractSerializer
      attr_reader :adapters, :record

      # class << self
      #   def serialize(record, options={})
      #   end
      #
      #   def serialize_each(collection)
      #     raise ArgumentError, "collection does not appear to be a collection" unless is_collection?(collection)
      #     new(collection).serializable_hash
      #   end
      #
      #   def is_collection?(object)
      #     object.respond_to?(:each) && !object.respond_to?(:each_pair)
      #   end
      # end
    end
  end
end
