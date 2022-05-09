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
      __getobj__.name if __getobj__.respond_to?(:name)
    end

    def role
      __getobj__.role if __getobj__.respond_to?(:role)
    end

    def name_type
      return if name.blank?

      name.name_type
    end

    def name_authority
      return if name.blank?

      name.authority_code
    end

    def name_authority_uri
      return if name.blank?

      name.authority_base_url
    end

    def name_value_uri
      return if name.blank?

      name.value_uri
    end

    def role_term
      Mappings::RoleTermModsPresenter.new(role) if role.present?
    end
    # @returns [Boolean] - Needed for serializer
    def blank?
      return true if __getobj__.blank?

      name.blank? && role.blank?
    end
  end
end
