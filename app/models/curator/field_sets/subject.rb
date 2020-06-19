# frozen_string_literal: true

module Curator
  class FieldSets::Subject < FieldSets::Base
    attr_json :titles, FieldSets::Title.to_type, array: true, default: []
    attr_json :temporals, :string, array: true, default: []
    attr_json :dates, :string, array: true, default: []
  end
end
