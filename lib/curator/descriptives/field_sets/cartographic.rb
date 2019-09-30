# frozen_string_literal: true
module Curator
  module Descriptives
    class Cartographic < FieldSet
      attr_json :scale, :string, array: true, default: []
      attr_json :projection, :string
    end
  end
end
