# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::Note < DescriptiveFieldSets::Base
    attr_json :label, :string
    attr_json :type, :string

    validates :type, allow_blank: true, inclusion: { in: DescriptiveFieldSets::NOTE_TYPES }
  end
end
