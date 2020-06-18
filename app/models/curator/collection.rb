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

    with_options through: :admin_set_objects do
      has_many :file_sets, source: :file_sets do
        def exemplaryable
          where(file_set_type: EXEMPLARYABLE_FILE_SETS)
        end
      end
      has_many :audio_file_sets, source: :audio_file_sets
      has_many :image_file_sets, source: :image_file_sets
      has_many :document_file_sets, source: :document_file_sets
      has_many :ereader_file_sets, source: :ereader_file_sets
      has_many :metadata_file_sets, source: :metadata_file_sets
      has_many :text_file_sets, source: :text_file_sets
      has_many :video_file_sets, source: :video_file_sets
    end

    validates :name, presence: true

    after_update_commit :reindex_collection_members

    private

    def reindex_collection_members
      collection_members.find_each { |col_mem| col_mem.digital_object.update_index } if saved_change_to_name?
    end
  end
end
