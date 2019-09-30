# frozen_string_literal: true
module Curator
  module Descriptives
    class Subject < FieldSet
      attr_json :title, Descriptives::Title.to_type, array: true, default: []
      attr_json :temporal, :string, array: true, default: []
      attr_json :date, :string, array: true, default: []
    end
  end
end
