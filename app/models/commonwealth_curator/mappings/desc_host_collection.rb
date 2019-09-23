# frozen_string_literal: true
module CommonwealthCurator
  class Mappings::DescHostCollection < ApplicationRecord
    belongs_to :host_collection, inverse_of: :desc_host_collections, class_name: 'CommonwealthCurator::Mappings::HostCollection'
    belongs_to :descriptive, inverse_of: :desc_host_collections, class_name: 'CommonwealthCurator::Metastreams::Descriptive'

    validates :host_collection_id, uniqueness: { scope: :descriptive_id, allow_nil: true }
  end
end
