# frozen_string_literal: true

module Curator
  class Institution < ApplicationRecord
    self.table_name = 'curator.institutions'

    include Curator::Indexable
    include Curator::Mintable
    include Curator::Metastreamable::Basic
    include Curator::Mappings::Exemplary::Object

    self.curator_indexable_mapper = Curator::InstitutionIndexer.new

    scope :with_location, -> { includes(location: :authority) }
    scope :for_serialization, -> { includes(exemplary_image_mapping: :exemplary_file_set).with_metastreams.with_location.includes(:host_collections) }
    scope :for_reindex_all, -> { for_serialization.joins(:administrative, :workflow) }
    scope :local_id_finder, ->(name) { where(name: name).limit(1) }

    validates :url, format: { with: URI.regexp(%w(http https)), allow_blank: true }
    validates :name, presence: true

    belongs_to :location, inverse_of: :institution_locations, class_name: 'Curator::ControlledTerms::Geographic', optional: true

    # host_collections is a mapping object (metadata) not to be confused with collections (repository set)
    has_many :host_collections, inverse_of: :institution, class_name: 'Curator::Mappings::HostCollection', dependent: :destroy

    has_many :collections, inverse_of: :institution, class_name: 'Curator::Collection', dependent: :destroy

    has_many :collection_admin_set_objects, through: :collections, source: :admin_set_objects

    accepts_nested_attributes_for :host_collections, allow_destroy: true, reject_if: :all_blank

    after_update_commit :reindex_associations

    with_options through: :collection_admin_set_objects do
      has_many :file_sets, source: :file_sets do
        def exemplaryable
          where(file_set_type: EXEMPLARYABLE_FILE_SETS)
        end
      end
      has_many :image_file_sets, source: :image_file_sets
      has_many :document_file_sets, source: :document_file_sets
      has_many :metadata_file_sets, source: :metadata_file_sets
      has_many :video_file_sets, source: :video_file_sets
    end

    def ark_params
      super.except(:oai_namespace_id).merge({
        parent_pid: nil,
          secondary_parent_pids: [],
          local_original_identifier_type: 'physical_location',
          local_original_identifier: name
      })
    end

    private

    def reindex_associations
      return if !saved_change_to_name?

      collections.includes(:collection_members).find_each do |col|
        reindex_jobs = col.collection_members.pluck(:digital_object_id).map do |digital_object_id|
          Curator::Indexer::IndexingJob.new(Curator.digital_object_class.name, digital_object_id).set(wait: 2.seconds)
        end

        reindex_jobs << Curator::Indexer::IndexingJob.new(col.class.name col.id).set(wait: 2.seconds)

        ActiveJob.perform_all_later(reindex_jobs)
      end
    end
  end
end
