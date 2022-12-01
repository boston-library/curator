# frozen_string_literal: true

module Curator
  class DigitalObject < ApplicationRecord
    self.table_name = 'curator.digital_objects'

    include Curator::Mintable
    include Curator::Metastreamable::All
    include Curator::Mappings::Exemplary::Object
    include Curator::Indexable

    has_paper_trail skip: %i(lock_version)

    self.curator_indexable_mapper = Curator::DigitalObjectIndexer.new

    scope :for_serialization, -> { includes(:file_sets, exemplary_image_mapping: :exemplary_file_set).with_metastreams }
    scope :for_reindex_all, -> { for_serialization.joins(:administrative, :descriptive, :workflow) }
    scope :local_id_finder, lambda { |admin_set_ark_id, identifier, oai_header_id = nil|
      return joins(:admin_set, :administrative).where(collections: { ark_id: admin_set_ark_id }).merge(Curator.metastreams.administrative_class.local_id_finder(oai_header_id)).limit(1) if oai_header_id

      joins(:admin_set, :descriptive).where(collections: { ark_id: admin_set_ark_id }).merge(Curator.metastreams.descriptive_class.local_id_finder(identifier)).limit(1)
    }

    validates :contained_by_id, exclusion: { in: -> (digital_object) { Array.wrap(digital_object.id) } },
              uniqueness: { scope: :id }, unless: -> { contained_by.blank? }

    before_create :add_admin_set_to_members
    after_destroy_commit :invalidate_iiif_manifest

    belongs_to :admin_set, inverse_of: :admin_set_objects, class_name: 'Curator::Collection'
    belongs_to :contained_by, inverse_of: :container_for, class_name: 'Curator::DigitalObject', optional: true

    has_one :institution, through: :admin_set, class_name: 'Curator::Institution'

    with_options inverse_of: :file_set_of, foreign_key: :file_set_of_id, dependent: :destroy do
      has_many :file_sets, class_name: 'Curator::Filestreams::FileSet' do
        def exemplaryable
          where(file_set_type: EXEMPLARYABLE_FILE_SETS)
        end
      end

      has_many :audio_file_sets, class_name: 'Curator::Filestreams::Audio'
      has_many :image_file_sets, class_name: 'Curator::Filestreams::Image'
      has_many :document_file_sets, class_name: 'Curator::Filestreams::Document'
      has_many :ereader_file_sets, class_name: 'Curator::Filestreams::Ereader'
      has_many :metadata_file_sets, class_name: 'Curator::Filestreams::Metadata'
      has_many :text_file_sets, class_name: 'Curator::Filestreams::Text'
      has_many :video_file_sets, class_name: 'Curator::Filestreams::Video'
    end

    has_many :container_for, inverse_of: :contained_by, class_name: 'Curator::DigitalObject',
             foreign_key: :contained_by_id, dependent: :nullify

    has_many :collection_members, -> { includes(:collection) }, inverse_of: :digital_object, autosave: true,
             class_name: 'Curator::Mappings::CollectionMember', dependent: :destroy do
      def can_remove
        where.not(collection_id: proxy_association.owner.admin_set_id)
      end
    end

    has_many :is_member_of_collection, through: :collection_members, source: :collection

    has_many :file_set_member_mappings, -> { includes(:file_set) }, inverse_of: :digital_object,
             class_name: 'Curator::Mappings::FileSetMember', dependent: :destroy
    with_options through: :file_set_member_mappings, source: :file_set do
      has_many :file_set_members, class_name: 'Curator::Filestreams::FileSet'
      has_many :audio_file_set_members, class_name: 'Curator::Filestreams::Audio'
      has_many :image_file_set_members, class_name: 'Curator::Filestreams::Image'
      has_many :document_file_set_members, class_name: 'Curator::Filestreams::Document'
      has_many :ereader_file_set_members, class_name: 'Curator::Filestreams::Ereader'
      has_many :metadata_file_set_members, class_name: 'Curator::Filestreams::Metadata'
      has_many :text_file_set_members, class_name: 'Curator::Filestreams::Text'
      has_many :video_file_set_members, class_name: 'Curator::Filestreams::Video'
    end

    def all_file_sets_complete?
      return false if file_sets.blank?

      Curator.metastreams.workflow_class.select(:workflowable_type, :workflowable_id, :processing_state).where(workflowable_type: 'Curator::Filestreams::FileSet', workflowable_id: file_set_ids).all?(&:complete?)
    end

    def ark_params
      return super.except(:oai_namespace_id).merge({
        parent_pid: admin_set&.ark_id,
        secondary_parent_pids: []
      }.merge(local_id_params)) if !oai_object?

      params = super.merge({
        parent_pid: admin_set&.ark_id,
        secondary_parent_pids: []
      }.merge(local_id_params))
      params[:namespace_id] = params.delete(:oai_namespace_id)
      params
    end

    private

    def local_id_params
      ident_params = { local_original_identifier: nil, local_original_identifier_type: nil }

      return {
        local_original_identifier: administrative.oai_header_id,
              local_original_identifier_type: 'oai_header_id'
      } if administrative&.oai_header_id.present?

      return ident_params if descriptive&.identifier.blank?

      ident_params.merge(fetch_local_id_by_precedent)
    end

    # Sets an array of local_id_types by the same precedent the case/when was setting in the previous
    # Chose this way because of a one off bug i noticed that return local_id_params as an array
    # Version above works as intended with the right precedent being used and avoids returning an array
    # Method below is a helper method that builds the constant into a 2d array. The constant is also ordered
    # by precedent to ensure that the order is maintained.
    #
    # UPDATE: Changed this method to fetch the identifer params based on the order of the keys in the hash.
    # Due to it causing issues with the NDNP btach processing. Rather than create a 2D array It iterates through the keys
    # of the LOCAL_ORIGINAL_IDENTIFIER_TYPES (which is still ordered by precedent). The method below is the equivalent of
    # a case when statement like so
    # For reference here how the local id params were being set before.
    #   case ident.type
    # when 'local-filename',
    #   return {
    #     local_original_identifier: ident.label,
    #       local_original_identifier_type: 'filename'
    #   }
    # when 'internet-archive',
    #   return {
    #     local_original_identifier: ident.label,
    #       local_original_identifier_type: 'barcode'
    #   }
    # when 'local-barcode'
    #   return {
    #     local_original_identifier: ident.label,
    #       local_original_identifier_type: 'barcode'
    #   }
    # when 'local-accession'
    #   return {
    #     local_original_identifier: ident.label,
    #       local_original_identifier_type: 'id_local-accession'
    #   }
    # when 'local-other'
    #   return {
    #     local_original_identifier: ident.label,
    #       local_original_identifier_type: 'id_local-other'
    #   }
    # when 'lccn'
    #   return {
    #     local_original_identifier: ident.label,
    #       local_original_identifier_type: 'id_local-other'
    #   }

    def fetch_local_id_by_precedent
      local_ident_for_params = {}
      DescriptiveFieldSets::LOCAL_ORIGINAL_IDENTIFIER_TYPES.keys.each do |local_id_type|
        ident = descriptive.identifier.find { |i| i.type == local_id_type }

        next if ident.blank?

        break local_ident_for_params = { local_original_identifier: ident.label, local_original_identifier_type: ident.local_original_identifier_type }
      end

      local_ident_for_params
    end

    def add_admin_set_to_members
      collection_members.build(collection: admin_set) if admin_set.present?
    end

    def invalidate_iiif_manifest
      Curator::IIIFManifestInvalidateJob.set(wait: 2.seconds).perform_later(ark_id)
    end
  end
end
