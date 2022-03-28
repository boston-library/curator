# frozen_string_literal: true

module Curator
  class Filestreams::TextSerializer < Filestreams::FileSetSerializer
    build_schema_as_json {}
  end
end
