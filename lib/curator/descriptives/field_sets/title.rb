# frozen_string_literal: true
module Curator
  module Descriptives
    class Title < FieldSet
      attr_json :label, :string
      attr_json :subtitle, :string
      attr_json :display, :string
      attr_json :display_label, :string
      attr_json :usage, :string
      attr_json :supplied, :boolean
      attr_json :language, :string
      attr_json :type, :string
      attr_json :authority_code, :string
      attr_json :id_from_auth, :string
      attr_json :part_number, :string
      attr_json :part_name, :string
    end


    class TitleSet < FieldSet
      attr_json :title_primary, Title.to_type
      attr_json :title_other, Title.to_type, array: true, default: []

      validates :title_primary, presence: true
    end
  end
end
