# frozen_string_literal: true

module Curator
  class Filestreams::FileSetUpdaterService < Services::Base
    SIMPLE_ATTRIBUTES_LIST = %i(position).freeze
    PAGINATION_ATTRIBUTES_LIST = %i(page_label page_type hand_side).freeze

    include Services::UpdaterService
    include Filestreams::Attacher

    def call
      exemplary_image_of_attrs = @json_attrs.fetch(:exemplary_image_of, [])
      pagination_attrs = @json_attrs.fetch(:pagination, {})
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end
        update_pagination!(pagination_attrs)
        update_exemplary_image_of!(exemplary_image_of_attrs) if has_exemplary_image_of?
        attach_files!(@record)
        @record.save!
      end
      return @success, @result
    end

    protected

    def file_set_class
      return @file_set_class if defined?(@file_set_class)

      @file_set_class = @record.class
    end

    def has_exemplary_image_of?
      Curator::Mappings::ExemplaryImage::VALID_EXEMPLARY_FILE_SET_TYPES.include?(@record.class.name.demodulize)
    end

    def update_exemplary_image_of!(exemplary_image_of_attrs = [])
      return if exemplary_image_of_attrs.blank?

      should_add_exemplary = ->(ex_img_attrs) { !SHOULD_REMOVE.call(ex_img_attrs) }

      exemplaries_to_add = exemplary_image_of_attrs.select(&should_add_exemplary).pluck('ark_id')
      exemplaries_to_remove = exemplary_image_of_attrs.select(&SHOULD_REMOVE).pluck('ark_id')

      return if exemplaries_to_add.blank? && exemplaries_to_remove.blank?

      add_exemplary_image_of!(exemplaries_to_add)
      remove_exemplary_image_of!(exemplaries_to_remove)
    end

    def update_pagination!(pagination_attrs = {})
      return if pagination_attrs.empty?

      PAGINATION_ATTRIBUTES_LIST.each do |pagination_attr|
        @record.public_send("#{pagination_attr}=", pagination_attrs[pagination_attr]) if pagination_attrs[pagination_attr].present?
      end
    end

    private

    def add_exemplary_image_of!(exemplary_object_ark_ids = [])
      return if exemplary_object_ark_ids.blank?

      exemplary_object_ark_ids.each do |ex_obj_ark_id|
        ex_obj = Curator.digital_object_class.find_by(ark_id: ex_obj_ark_id) ||
                 Curator.collection_class.find_by!(ark_id: ex_obj_ark_id)

        @record.exemplary_image_of_mappings.build(exemplary_object: ex_obj)
      end
    rescue ActiveRecord::RecordNotFound => e
      @record.errors.add(:exemplary_image_of_mappings, "#{e.message} with ark_id=#{admin_set_ark_id}")
      raise ActiveRecord::RecordInvalid, @record
    end

    def remove_exemplary_image_of!(exemplary_object_ark_ids = [])
      return if exemplary_object_ark_ids.blank?

      exemplary_object_ark_ids.each do |ex_obj_ark_id|
        ex_obj = Curator.digital_object_class.find_by(ark_id: ex_obj_ark_id) ||
                 Curator.collection_class.find_by!(ark_id: ex_obj_ark_id)
        @record.exemplary_image_of_mappings.where(exemplary_object: ex_obj).destroy_all
      end
    rescue ActiveRecord::RecordNotFound => e
      @record.errors.add(:exemplary_image_of_mappings, "#{e.message} with ark_id=#{admin_set_ark_id}")
      raise ActiveRecord::RecordInvalid, @record
    end
  end
end
