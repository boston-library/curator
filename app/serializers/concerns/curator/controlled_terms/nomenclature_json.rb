# frozen_string_literal: true

module Curator
  module ControlledTerms
    module NomenclatureJson
      extend ActiveSupport::Concern

      included do
        attributes :label, :id_from_auth
      end
    end
  end
end
