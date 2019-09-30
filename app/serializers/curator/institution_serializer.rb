# frozen_string_literal: true
module Curator
  class InstitutionSerializer < CuratorSerializer
    attributes :ark_id, :abstract, :name
  end
end
