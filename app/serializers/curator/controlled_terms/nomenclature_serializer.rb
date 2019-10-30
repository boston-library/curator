# frozen_string_literal: true

module Curator
  class ControlledTerms::NomenclatureSerializer < CuratorSerializer
    attributes :label, :id_from_auth
  end
end
