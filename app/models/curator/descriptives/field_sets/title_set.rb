# frozen_string_literal: true

require_dependency 'curator/descriptives/field_sets/title'
module Curator
  class Descriptives::TitleSet < Descriptives::FieldSet
    attr_json :primary, Descriptives::Title.to_type, store_key: 'primary'
    attr_json :other, Descriptives::Title.to_type, store_key: 'other', array: true, default: []

    validates :primary, presence: true
  end
end
