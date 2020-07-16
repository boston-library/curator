# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::Date < DescriptiveFieldSets::Base
    attr_json :created, :string
    attr_json :issued, :string
    attr_json :copyright, :string
  end
end
