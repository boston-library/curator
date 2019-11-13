# frozen_string_literal: true

module Curator
  class Descriptives::Identifier < Descriptives::FieldSet
    attr_json :label, :string
    attr_json :type, :string
    attr_json :invalid, :boolean, default: false

    validates :type, presence: true, inclusion: { in: Descriptives::IDENTIFIER_TYPES, allow_blank: true }
    validates :label, presence: true
  end
end
