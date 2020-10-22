# frozen_string_literal: true

module Curator
  class Filestreams::FileSetFactoryService < Services::Base
    include Services::FactoryService
    include Filestreams::Attacher

    def initialize(json_data: {})
      super(json_data: json_data)

      @file_set_type = @json_attrs.fetch('file_set_type')
    end

    def call
      with_transaction do
        object_ark_id = @json_attrs.dig('file_set_of', 'ark_id')
        obj = Curator.digital_object_class.find_by!(ark_id: object_ark_id)
        @record = file_set_class.where(ark_id: @ark_id).first_or_create! do |file_set|
          file_set.file_set_of = obj
          file_set.file_name_base = @json_attrs.fetch('file_name_base')
          file_set.position = @json_attrs.fetch('position', 0)
          file_set.pagination = @json_attrs.fetch('pagination', {})
          file_set.created_at = @created if @created
          file_set.updated_at = @updated if @updated

          # set exemplary relationships
          map_exemplary_objects!

          build_workflow(file_set) do |workflow|
            workflow.send('ingest_origin=', @workflow_json_attrs.fetch(:ingest_origin, ENV['HOME'].to_s))
            processing_state = @workflow_json_attrs.fetch(:processing_state, nil)
            publishing_state = obj&.workflow&.publishing_state
            # set publishing state to same value as parent DigitalObject
            workflow.send('processing_state=', processing_state) if processing_state
            workflow.send('publishing_state=', publishing_state) if publishing_state
          end

          # TODO: set access_edit_group permissions
          build_administrative(file_set) do |administrative|
            access_edit_group = nil
            # access_edit_group = @admin_json_attrs.fetch(:access_edit_group, nil)
            administrative.send('access_edit_group=', access_edit_group) if access_edit_group
          end
          attach_files!(file_set)
        end


      end
      return @success, @result
    end

    protected

    def file_set_class
      return @file_set_class if defined?(@file_set_class)

      @file_set_class = Curator.filestreams.public_send("#{@file_set_type}_class")
    end

    private

    def map_exemplary_objects!
      return if Curator::Mappings::ExemplaryImage::VALID_EXEMPLARY_FILE_SET_TYPES.include?(@file_set_type.camelize)

      exemplary_ids = @json_attrs.fetch('exemplary_image_of', []).pluck('ark_id')

      return if exemplary_ids.blank?

      exemplary_ids.each do |ex_ark_id|
        ex_obj = Curator.digital_object_class.find_by(ark_id: ex_ark_id) ||
                 Curator.collection_class.find_by(ark_id: ex_ark_id)

        raise ActiveRecord::RecordNotSaved, "Bad exemplary id! #{ex_ark_id} is either not in the repo or is not a DigitalObject or Collection" unless ex_obj

        ex_obj.lock!
        build_exemplary(file_set) do |exemplary_img|
          exemplary_img.exemplary_object = ex_obj
        end
      end
    end
  end
end
