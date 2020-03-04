# frozen_string_literal: true

module Curator
  class Collection < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreamable::Basic
    include Curator::Mappings::Exemplary::Object
    include Curator::Indexable

    self.curator_indexable_mapper = Curator::CollectionIndexer.new

    scope :for_serialization, -> { with_metastreams }

    belongs_to :institution, inverse_of: :collections, class_name: 'Curator::Institution'

    has_many :admin_set_objects, inverse_of: :admin_set, class_name: 'Curator::DigitalObject', foreign_key: :admin_set_id, dependent: :destroy

    has_many :collection_members, inverse_of: :collection, class_name: 'Curator::Mappings::CollectionMember', dependent: :destroy
  end
end
