# frozen_string_literal: true
module Curator
  class CollectionSerializer < CuratorSerializer
    attributes :ark_id, :abstract, :name
  end
end
