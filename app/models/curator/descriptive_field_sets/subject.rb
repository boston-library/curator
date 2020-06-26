# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::Subject < DescriptiveFieldSets::Base
    attr_json :titles, DescriptiveFieldSets::Title.to_type, array: true, default: []
    attr_json :temporals, :string, array: true, default: []
    attr_json :dates, :string, array: true, default: []
  end
end
