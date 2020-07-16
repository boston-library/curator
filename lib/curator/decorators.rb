# frozen_string_literal: true

module Curator
  module Decorators
    extend ActiveSupport::Autoload
    class BaseDecorator < SimpleDelegator
      include ActiveModel::Serialization

      # NOTE: Because of how the serializer current works records are checked with .blank? before being read_for_serialization
      # Due to the fact the SimplmeDelegator class does not include active support core extensions this will fail on that check with the following NameError
      # NameError: undefined method `blank?' for module `Kernel'
      # Due to this I am adding making the .blank? method be required by classes that inherit from this(BaseDecorator) class
      def blank?
        raise 'I need to be implemented in the class'
      end

      # NOTE: this is needed for ActiveModel::Serialization to work
      # Can override as needed
      def attributes
        {}
      end
    end
  end
end
