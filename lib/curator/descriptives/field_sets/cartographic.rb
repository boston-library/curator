# frozen_string_literal: true
module Curator
  module Descriptives
    class Cartographic < FieldSet
      attr_json :scale, :string, store_key: 'scale', array: true, default: []
      attr_json :projection, :string, store_key: 'projection'
    end
  end
end
