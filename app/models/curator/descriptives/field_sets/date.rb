# frozen_string_literal: true

module Curator
  class Descriptives::Date < Descriptives::FieldSet
    attr_json :created, :string
    attr_json :issued, :string
    attr_json :copyright, :string
  end
end
