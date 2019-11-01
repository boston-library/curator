# frozen_string_literal: true

module Curator
  module Descriptives
    class FieldSet
      include AttrJson::Model
      # rubocop:disable Style/AccessModifierDeclarations
      public :read_attribute_for_serialization
      # rubocop:enable Style/AccessModifierDeclarations
    end
  end
end
