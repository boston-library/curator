# frozen_string_literal: true

module Curator
  class Descriptives::Note < Descriptives::FieldSet
    attr_json :label, :string
    attr_json :type, :string

    validates :type, presence: true, inclusion: { in: Descriptives::NOTE_TYPES }
  end
end
