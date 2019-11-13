# frozen_string_literal: true
require_dependency 'curator/descriptives/field_sets/title'
module Curator
  class Descriptives::Subject < Descriptives::FieldSet
    attr_json :titles, Descriptives::Title.to_type, array: true, default: []
    attr_json :temporals, :string, array: true, default: []
    attr_json :dates, :string, array: true, default: []
  end
end
