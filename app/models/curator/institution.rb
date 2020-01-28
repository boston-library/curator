# frozen_string_literal: true

module Curator
  class Institution < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreams::Administratable
    include Curator::Metastreams::Workflowable
    include Curator::Indexable

    validates :url, format: { with: URI.regexp(%w(http https)), allow_blank: true }

    belongs_to :location, -> { includes(:authority) }, inverse_of: :institution_locations, class_name: 'Curator::ControlledTerms::Geographic', optional: true

    has_many :host_collections, inverse_of: :institution, class_name: 'Curator::Mappings::HostCollection', dependent: :destroy
    # host_collections is a mapping object not to be consfused with collections
    has_many :collections, inverse_of: :institution, class_name: 'Curator::Collection', dependent: :destroy

    has_many :collection_admin_set_objects, through: :collections, source: :admin_set_objects

    self.curator_indexable_mapper = Curator::InstitutionIndexer.new
  end
end
