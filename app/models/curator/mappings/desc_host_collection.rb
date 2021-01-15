# frozen_string_literal: true

module Curator
  class Mappings::DescHostCollection < ApplicationRecord
    belongs_to :host_collection, inverse_of: :desc_host_collections, class_name: 'Curator::Mappings::HostCollection'
    belongs_to :descriptive, inverse_of: :desc_host_collections, class_name: 'Curator::Metastreams::Descriptive'

    validates :host_collection_id, uniqueness: { scope: :descriptive_id }

    has_paper_trail
  end
end
