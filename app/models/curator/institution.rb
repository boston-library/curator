# frozen_string_literal: true

module Curator
  class Institution < ApplicationRecord
    include Curator::Indexable
    include Curator::Mintable
    include Curator::Metastreamable::Basic
    include Curator::Filestreams::Thumbnailable

    self.curator_indexable_mapper = Curator::InstitutionIndexer.new

    scope :with_location, -> { joins(:location).preload(:location) }
    scope :for_serialization, -> { merge(with_location).merge(with_metastreams) }

    validates :url, format: { with: URI.regexp(%w(http https)), allow_blank: true }
    validates :name, presence: true

    belongs_to :location, -> { merge(with_authority) }, inverse_of: :institution_locations, class_name: 'Curator::ControlledTerms::Geographic', optional: true

    has_many :host_collections, inverse_of: :institution, class_name: 'Curator::Mappings::HostCollection', dependent: :destroy
    # host_collections is a mapping object not to be consfused with collections
    has_many :collections, inverse_of: :institution, class_name: 'Curator::Collection', dependent: :destroy

    has_many :collection_admin_set_objects, through: :collections, source: :admin_set_objects

    after_update_commit :reindex_associations

    private

    def reindex_associations
      return unless saved_change_to_name?

      collections.find_each do |col|
        col.collection_members.find_each { |col_mem| col_mem.digital_object.update_index }
        col.update_index
      end
    end
  end
end
