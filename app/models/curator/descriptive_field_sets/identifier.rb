# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::Identifier < DescriptiveFieldSets::Base
    attr_json :label, :string
    attr_json :type, :string
    attr_json :invalid, :boolean, default: false

    validates :type, presence: true, inclusion: { in: DescriptiveFieldSets::IDENTIFIER_TYPES, allow_blank: true }
    validates :label, presence: true

    def local_original_identifier_type
      DescriptiveFieldSets::LOCAL_ORIGINAL_IDENTIFIER_TYPES[type]
    end
  end
end
