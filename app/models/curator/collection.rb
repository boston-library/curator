# frozen_string_literal: true

module Curator
  class Collection < ApplicationRecord
    self.table_name = 'curator.collections'

    include Curator::Mintable
    include Curator::Metastreamable::Basic
    include Curator::Mappings::Exemplary::Object
    include Curator::Indexable

    self.curator_indexable_mapper = Curator::CollectionIndexer.new

    scope :for_serialization, -> { includes(exemplary_image_mapping: :exemplary_file_set).with_metastreams }
    scope :for_reindex_all, -> { for_serialization.joins(:administrative, :workflow) }
    scope :local_id_finder, ->(institution_ark_id, name) { joins(:institution).where(institutions: { ark_id: institution_ark_id }, name: name).limit(1) }

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

    def ark_params
      return super.except(:oai_namespace_id).merge({
        parent_pid: institution&.ark_id,
          secondary_parent_pids: [],
          local_original_identifier_type: 'institution_collection_name',
          local_original_identifier: name
      }) if !oai_object?

      params = super.merge({
        parent_pid: institution&.ark_id,
          secondary_parent_pids: [],
          local_original_identifier_type: 'institution_collection_name',
          local_original_identifier: name
      })
      params[:namespace_id] = params.delete(:oai_namespace_id)
      params
    end

    private

    def reindex_collection_members
      return if !saved_change_to_name?

      Curator.digital_object_class.where(id: collection_members.pluck(:digital_object_id)).find_each do |obj|
        obj.queue_indexing_job
        sleep(0.1)
      end
    end
  end
end
