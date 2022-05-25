# frozen_string_literal: true

module Curator
  class Metastreams::PhysicalDescriptionModsDecorator < Decorators::BaseDecorator
    # DESCRIPTION: This class wraps and delegates a Curator::Metastreams::Descriptive to serialize and display sub elements for <mods:physicalDescription>
    # PhysicalDescriptionModsDecorator#initialize
    ## @param obj [Curator::Metastreams::Descriptive]
    ## @return [Curator::Metastreams::RecordInfoModsDecorator]
    ## USAGE:
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### physical_description = Curator::Metastreams:PhysicalDescriptionModsDecorator.new(desc)
    include Curator::DigitalObjectable

    EXCLUDED_PD_MODS_MEDIA_TYPES = %w(xml text).freeze

    # @return [String | nil] - <mods:digitalOrigin> sub element
    def digital_origin
      super.tr('_', ' ') if __getobj__.respond_to?(:digital_origin)
    end

    # @return [String | nil] - <mods:extent> sub element
    def extent
      super if __getobj__.respond_to?(:extent)
    end

    def note
      super if __getobj__.respond_to?(:note)
    end

    def file_sets
      return [] if digital_object.blank? || digital_object.file_sets.blank?

      digital_object.file_sets
    end

    # @return [Array[Curator::DescriptiveFieldSets::Note]] - <mods:note> sub element
    def physical_description_note_list
      return @physical_description_note_list if defined?(@physical_description_note_list)

      return @physical_description_note_list = [] if note.blank?

      @physical_description_note_list = note.select { |n| n.type == 'physical description' }
    end

    # @return [Array[String]] - <mods:internetMediaType> sub elements
    def internet_media_type_list
      return @internet_media_type_list if defined?(@internet_media_type_list)

      return @internet_media_type_list = [] if file_sets.blank?

      @internet_media_type_list = ActiveStorage::Attachment.includes(:blob).where(record: file_sets).pluck(Arel.sql('curator.active_storage_blobs.content_type')).uniq.select { |imt| EXCLUDED_PD_MODS_MEDIA_TYPES.all? { |mt| imt.exclude?(mt) } }
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      digital_origin.blank? && extent.blank? && physical_description_note_list.blank? && internet_media_type_list.blank?
    end
  end
end
