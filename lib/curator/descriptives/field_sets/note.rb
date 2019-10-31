# frozen_string_literal: true

module Curator
  module Descriptives
    class Note < FieldSet
      NOTE_TYPES = ["date", "language", "acquisition", "ownership", "funding", "biographical/historical", "citation/reference", "preferred citation", "bibliography", "exhibitions", "publication", "creation/production credits", "performers", "physical-description", "venue", "arrangement", "statement of responsibility"].freeze

      attr_json :label, :string
      attr_json :type, :string

      validates :type, presence: true, inclusion: {in: NOTE_TYPES, allow_blank: true }
    end
  end
end
