# frozen_string_literal: true

module Curator
  class Descriptives::Cartographic < Descriptives::FieldSet
    attr_json :scale, :string, array: true, default: []
    attr_json :projection, :string
  end
end
