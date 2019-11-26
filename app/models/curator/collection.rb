# frozen_string_literal: true

module Curator
  class Collection < ApplicationRecord
    include Curator::Mintable
    include Curator::Metastreams::Administratable
    include Curator::Metastreams::Workflowable
    include Curator::Mappings::Exemplary::ObjectImagable
    include Curator::Indexable

    belongs_to :institution, inverse_of: :collections, class_name: 'Curator::Institution'

    has_many :admin_set_objects, inverse_of: :admin_set, class_name: 'Curator::DigitalObject', foreign_key: :admin_set_id, dependent: :destroy

    has_many :collection_members, inverse_of: :collection, class_name: 'Curator::Mappings::CollectionMember', dependent: :destroy

    self.curator_indexable_mapper = Curator::CollectionIndexer.new

    def exemplary_file_set
      exemplary_image_mapping = exemplary_image_mappings.first
      exemplary_image_mapping ? exemplary_image_mapping.exemplary_file_set : nil
    end
  end
end
