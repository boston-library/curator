# frozen_string_literal: true

module Curator
  class Mappings::NameRoleModsDecorator < Decorators::BaseDecorator
    class RoleTerm
      attr_reader :role

      def initialize(role)
        @role = role
      end

      delegate :label, :authority_code, :authority_base_url, :value_uri, to: :role, allow_nil: true
    end

    def name
      super if __getobj__.respond_to?(:name)
    end

    def role
      super if __getobj__.respond_to?(:role)
    end

    def name_part
      name&.label
    end

    def name_type
      name&.name_type
    end

    def name_authority
      name&.authority_code
    end

    def name_authority_uri
      name&.authority_base_url
    end

    def name_value_uri
      name&.value_uri
    end

    def role_term
      RoleTerm.new(role)
    end

    def blank?
      return true if __getobj__.blank?

      name.blank? && role.blank?
    end
  end
end
