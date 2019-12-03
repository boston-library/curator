# frozen_string_literal: true

module Curator
  module Serializers
    class XMLAdapter < Adapter

      def serializable_hash
      end
      alias_method :as_xml :serializable_hash

      def render
        Ox.dump(serializable_hash)
      end
      alias_method :to_xml, :render

    end
  end
end
