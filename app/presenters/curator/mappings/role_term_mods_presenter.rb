# frozen_string_literal: true

module Curator
  class Mappings::RoleTermModsPresenter
    # For serializing <mods:role><mods:roleTerm> elements

    attr_reader :role

    # @param role [Curator::ControlledTerms::Role]
    # @return [Curator::Mappings::RoleTermModsPresenter] instance
    def initialize(role)
      @role = role
    end

    delegate :label, :authority_code, :authority_base_url, :value_uri, to: :role, allow_nil: true
  end
end
