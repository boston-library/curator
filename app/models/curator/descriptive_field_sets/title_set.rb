# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::TitleSet < DescriptiveFieldSets::Base
    attr_json :primary, DescriptiveFieldSets::Title.to_type, store_key: 'primary'
    attr_json :other, DescriptiveFieldSets::Title.to_type, store_key: 'other', array: true, default: []

    validates :primary, presence: true
  end
end
