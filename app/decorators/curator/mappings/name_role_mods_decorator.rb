# frozen_string_literal: true

module Curator
  class Mappings::NameRoleModsDecorator < Decorators::BaseDecorator
    include Curator::ControlledTerms::NamePartableMods

    # This class wraps and delegates Curator::Mappings::NameRole objects to serialize/display <mods:name> elements and sub elements

    # @param name_roles [Array[Curator::Mappings::NameRole]]
    # @returns [Array[Curator::Mappings::NameRoleModsDecorator]]
    def self.wrap_multiple(name_roles = [])
      name_roles.map(&method(:new))
    end

    def name
      super if __getobj__.respond_to?(:name)
    end

    def role
      super if __getobj__.respond_to?(:role)
    end

    # @return [String] - Used for <mods:name type=''> attribute value
    def name_type
      return if name.blank?

      name.name_type
    end

    # @return [String] - Used for <mods:name authority=''> attribute value
    def name_authority
      return if name.blank?

      name.authority_code
    end

    # @return [String] - Used for <mods:name authorityURI=''> attribute value
    def name_authority_uri
      return if name.blank?

      name.authority_base_url
    end

    # @return [String] - Used for <mods:name valueURI=''> attribute value
    def name_value_uri
      return if name.blank?

      name.value_uri
    end

    def name_affiliation
      return if name.blank?

      name.affiliation
    end

    # @return [Curator::Mappings::RoleTermModsPresenter | nil] - Used for <mods:role><mods:roleTerm> sub elements
    def role_term
      Mappings::RoleTermModsPresenter.new(role) if role.present?
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      name.blank? && role.blank?
    end
  end
end
