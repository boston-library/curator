# frozen_string_literal: true

module Curator
  module Descriptives
    class Subject < FieldSet
      attr_json :titles, Descriptives::Title.to_type, array: true, default: []
      attr_json :temporals, :string, array: true, default: []
      attr_json :dates, :string, array: true, default: []
    end
  end
end
