# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::ReferencedBy < DescriptiveFieldSets::Base
    attr_json :label, :string
    attr_json :url, :string

    validates :url, presence: true
  end
end
