# frozen_string_literal: true

module Curator
  class Mappings::RoleTermModsPresenter
    # For serializing <mods:role><mods:roleTerm> elements

    def self.wrap_multiple(roles = [])
      roles.map(&method(:new))
    end

    attr_reader :role

    # @param role [Curator::ControlledTerms::Role]
    # @return [Curator::Mappings::RoleTermModsPresenter] instance
    def initialize(role)
      @role = role
    end

    def type
      'text'
    end

    delegate :label, :authority_code, :authority_base_url, :value_uri, to: :role, allow_nil: true
  end
end
