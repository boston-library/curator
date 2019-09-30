# frozen_string_literal: true
module Curator
  class Institution < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreamable

    belongs_to :location, inverse_of: :institution_locations, class_name: Curator.controlled_terms.geographic_class.to_s, optional: true

    has_many :host_collections, inverse_of: :institution, class_name: Curator.mappings.host_collection_class.to_s
    #host_collections is a mapping object not to be consfused with collections
    has_many :collections, inverse_of: :institution, class_name: Curator.collection_class.to_s, dependent: :destroy

    has_many :collection_admin_set_digital_objects, through: :collections, source: :admin_set_digital_objects

  end
end
