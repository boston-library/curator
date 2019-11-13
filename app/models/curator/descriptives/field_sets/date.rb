# frozen_string_literal: true

module Curator
  class Descriptives::Date < Descriptives::FieldSet
    attr_json :created, :string, store_key: 'created'
    attr_json :issued, :string, store_key: 'issued'
    attr_json :copyright, :string, store_key: 'copyright'
  end
end
