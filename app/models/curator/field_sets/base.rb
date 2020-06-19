# frozen_string_literal: true

module Curator
  module FieldSets
    class Base
      include AttrJson::Model
      # rubocop:disable Style/AccessModifierDeclarations
      public :read_attribute_for_serialization
      # rubocop:enable Style/AccessModifierDeclarations
    end
  end
end
