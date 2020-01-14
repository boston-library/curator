# frozen_string_literal: true

module Curator
  class Filestreams::FileSetSerializer < CuratorSerializer
    schema_as_json do
      attributes :ark_id
    end
  end
end
