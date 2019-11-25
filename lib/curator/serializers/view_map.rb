# frozen_string_literal: true

module Curator
  module Serializers
    class ViewMap
      attr_reader :views
      def initialize
        @views = Concurrent::Hash.new
      end

      def register_view(view_name, **kwargs)
        @views.fetch(view_name.to_sym) do
          View.new(view_name, **kwargs)
        end
      end
      

    end
  end
end
