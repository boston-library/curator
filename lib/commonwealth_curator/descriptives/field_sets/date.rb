# frozen_string_literal: true
module CommonwealthCurator
  module Descriptives
    class Date < FieldSet
      attr_json :created, :string, store_key: 'created'
      attr_json :issued, :string, store_key: 'issued'
      attr_json :copyright, :string, store_key: 'copyright'
    end
  end
end
