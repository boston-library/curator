# frozen_string_literal: true

module Curator
  class Mappings::RoleTermModsPresenter
    attr_reader :role

    def initialize(role)
      @role = role
    end

    delegate :label, :authority_code, :authority_base_url, :value_uri, to: :role, allow_nil: true
  end
end
