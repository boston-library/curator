# frozen_string_literal: true
module CommonwealthCurator
  class Institution < ApplicationRecord
    include CommonwealthCurator::Mintable
    include CommonwealthCurator::Metastreamable

    belongs_to :location, inverse_of: :institution_locations, class_name: CommonwealthCurator.controlled_terms.geographic_class.to_s

    has_many :host_collections, inverse_of: :institution, class_name: CommonwealthCurator.mappings.host_collection_class.to_s
    #host_collections is a mapping object not to be consfused with collections
    has_many :collections, inverse_of: :institution, class_name: CommonwealthCurator.collection_class.to_s, dependent: :destroy

    has_many :collection_admin_set_digital_objects, through: :collections, source: :admin_set_digital_objects

  end
end
