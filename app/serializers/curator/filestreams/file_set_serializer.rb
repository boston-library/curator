# frozen_string_literal: true

module Curator
  class Filestreams::FileSetSerializer < CuratorSerializer
    schema_as_json do
      attributes :file_name_base
    end
  end
end
