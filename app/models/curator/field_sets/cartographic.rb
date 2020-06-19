# frozen_string_literal: true

module Curator
  class FieldSets::Cartographic < FieldSets::Base
    attr_json :scale, :string, array: true, default: []
    attr_json :projection, :string
  end
end
