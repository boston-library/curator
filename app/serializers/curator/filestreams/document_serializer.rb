# frozen_string_literal: true

module Curator
  class Filestreams::DocumentSerializer < Filestreams::FileSetSerializer
    schema_as_json do
      node :exemplary_image_of, target: ->(record) { record.exemplary_image_of_mappings } do
        attribute(:ark_id) { |record| record.exemplary_object.ark_id }
      end
    end
  end
end
