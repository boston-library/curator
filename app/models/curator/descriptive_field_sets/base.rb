# frozen_string_literal: true

module Curator
  module DescriptiveFieldSets
    class Base
      include AttrJson::Model

      attr_json_config(bad_cast: :as_nil, unknown_key: :strip)
    end
  end
end
