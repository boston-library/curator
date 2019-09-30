# frozen_string_literal: true
module Curator
  module Descriptives
    class Related < FieldSet
      attr_json :constituent, :string
      attr_json :other_format, :string, array: true, default: []
      attr_json :referenced_by_url, :string, array: true, default: []
      attr_json :references_url, :string, array: true, default: []
      attr_json :review_url, :string, array: true, default: []
    end
  end
end
