# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::Related < DescriptiveFieldSets::Base
    attr_json :constituent, :string
    attr_json :other_format, :string, array: true, default: []
    attr_json :referenced_by, DescriptiveFieldSets::ReferencedBy.to_type, array: true, default: []
    attr_json :references_url, :string, array: true, default: []
    attr_json :review_url, :string, array: true, default: []
  end
end
