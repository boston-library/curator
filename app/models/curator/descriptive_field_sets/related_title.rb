# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::RelatedTitle < DescriptiveFieldSets::Base
    attr_json :label, :string
    attr_json :control_number, :string

    validates :label, presence: true
  end
end
