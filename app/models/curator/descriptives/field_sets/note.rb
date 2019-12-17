# frozen_string_literal: true

module Curator
  class Descriptives::Note < Descriptives::FieldSet
    attr_json :label, :string
    attr_json :type, :string

    validates :type, allow_blank: true, inclusion: { in: Descriptives::NOTE_TYPES }
  end
end
