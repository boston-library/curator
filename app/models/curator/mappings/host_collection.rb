# frozen_string_literal: true
module Curator
  class Mappings::HostCollection < ApplicationRecord
    belongs_to :institution, inverse_of: :host_collections, class_name: Curator.institution_class.to_s

    validates :name, presence: true, uniqueness: {scope: :institution_id, allow_nil: true }

    has_many :desc_host_collections, inverse_of: :host_collection, class_name: Mappings.desc_host_collection_class.to_s
  end
end
