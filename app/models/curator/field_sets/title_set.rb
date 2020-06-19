# frozen_string_literal: true

module Curator
  class FieldSets::TitleSet < FieldSets::Base
    attr_json :primary, FieldSets::Title.to_type, store_key: 'primary'
    attr_json :other, FieldSets::Title.to_type, store_key: 'other', array: true, default: []

    validates :primary, presence: true
  end
end
