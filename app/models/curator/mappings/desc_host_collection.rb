# frozen_string_literal: true

module Curator
  class Mappings::DescHostCollection < ApplicationRecord
    belongs_to :host_collection, inverse_of: :desc_host_collections, class_name: Mappings.host_collection_class_name
    belongs_to :descriptive, inverse_of: :desc_host_collections, class_name: Curator.metastreams.descriptive_class_name

    validates :host_collection_id, uniqueness: { scope: :descriptive_id, allow_nil: true }
  end
end
