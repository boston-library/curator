# frozen_string_literal: true

module Curator
  class Metastreams::PhysicalDescriptionModsDecorator < Decorators::BaseDecorator
    def digital_origin
      super.tr('_', ' ') if __getobj__.respond_to?(:digital_origin)
    end

    def extent
      super if __getobj__.respond_to?(:extent)
    end

    def note
      super if __getobj__.respond_to?(:note)
    end

    def digital_object
      super if __getobj__.respond_to?(:digital_object)
    end

    def file_sets
      return [] if digital_object.blank? || digital_object.file_sets.blank?

      digital_object.file_sets
    end

    def physical_description_note_list
      return @physical_description_note_list if defined?(@physical_description_note_list)

      return @physical_description_note_list = [] if note.blank?

      @physical_description_note_list = note.select { |n| n.type == 'physical description' }
    end

    def internet_media_type_list
      return @internet_media_type_list if defined?(@internet_media_type_list)

      return @internet_media_type_list = [] if file_sets.blank?

      @internet_media_type_list = ActiveStorage::Attachment.includes(:blob).where(record: file_sets).pluck(Arel.sql('curator.active_storage_blobs.content_type')).uniq.select { |imt| Metastreams::EXCLUDED_PD_MODS_MEDIA_TYPES.any? { |mt| imt.include?(mt) } }
    end

    def blank?
      return true if __getobj__.blank?

      digital_origin.blank? && extent.blank? && physical_description_note_list.blank? && internet_media_type_list.blank?
    end
  end
end
