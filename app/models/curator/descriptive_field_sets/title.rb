# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::Title < DescriptiveFieldSets::Base
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

    def non_sort
      Curator::Parsers::InputParser.get_proper_title(label).first if label.present?
    end

    def authority
      return @authority if defined?(@authority)

      return @authority = nil if authority_code.blank?

      @authority = Curator::ControlledTerms::Authority.find_by(code: authority_code)
    end

    def authority_uri
      return if authority.blank?

      authority.base_url
    end

    def value_uri
      return if authority_uri.blank? && id_from_auth.blank?

      Addressable::URI.join("#{authority_uri}/", id_from_auth).to_s
    end
  end
end
