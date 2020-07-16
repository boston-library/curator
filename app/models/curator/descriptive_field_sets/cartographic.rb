# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::Cartographic < DescriptiveFieldSets::Base
    attr_json :scale, :string, array: true, default: []
    attr_json :projection, :string
  end
end
