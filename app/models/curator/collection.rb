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

    # NOTE: Should this include the file sets included by the collection members as well?
    with_options through: :admin_set_objects do
      has_many :file_sets, source: :file_sets do
        def exemplaryable
          exemplaryable_type = Curator::Mappings::ExemplaryImage::VALID_EXEMPLARY_FILE_SET_TYPES.map { |exemplary_file_type| "Curator::Filestreams::#{exemplary_file_type}" }
          where(file_set_type: exemplaryable_type)
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
  end
end
