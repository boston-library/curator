# frozen_string_literal: true

module Curator
  module Descriptives  
    class TitleSet < FieldSet
      attr_json :primary, Title.to_type, store_key: 'primary'
      attr_json :other, Title.to_type, store_key: 'other', array: true, default: []

      validates :primary, presence: true
    end
  end
end
