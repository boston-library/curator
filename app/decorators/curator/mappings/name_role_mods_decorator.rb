# frozen_string_literal: true

module Curator
  class Mappings::NameRoleModsDecorator < Decorators::BaseDecorator
    include Curator::ControlledTerms::NamePartableMods

    # This class wraps and delegates Curator::Mappings::NameRole objects to serialize/display <mods:name> elements and sub elements

    # @param name_roles [Array[Curator::Mappings::GroupedNameRoleModsPresenter]]
    # @returns [Array[Curator::Mappings::NameRoleModsDecorator]]
    def self.wrap_multiple(grouped_name_roles = [])
      grouped_name_roles.map(&method(:new))
    end

    def name
      super if __getobj__.respond_to?(:name)
    end

    def roles
      super if __getobj__.respond_to?(:roles)
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

    # @return [Array[Curator::Mappings::RoleTermModsPresenter | nil]] - Used for <mods:role><mods:roleTerm> sub elements
    def role_terms
      Mappings::RoleTermModsPresenter.wrap_multiple(roles) if roles.present?
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      name.blank? && roles.blank?
    end
  end
end
