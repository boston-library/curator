# frozen_string_literal: true

module Curator
  class Filestreams::FileSetFactoryService < Services::Base
    include Services::FactoryService

    def call
      with_transaction do
        object_ark_id = @json_attrs.dig('file_set_of', 'ark_id')
        file_set_type = @json_attrs.fetch('file_set_type', {})
        obj = Curator.digital_object_class.find_by(ark_id: object_ark_id)

        @record = Curator.filestreams.send("#{file_set_type}_class").find_or_initialize_by(ark_id: @ark_id)
        @record.file_set_of = obj
        @record.file_name_base = @json_attrs.fetch('file_name_base')
        @record.position = @json_attrs.fetch('position', 0)
        @record.pagination = @json_attrs.fetch('pagination', {})
        @record.created_at = @created if @created
        @record.updated_at = @updated if @updated

        # set exemplary relationships
        if Curator::Mappings::ExemplaryImage::VALID_EXEMPLARY_FILE_SET_TYPES.include?(file_set_type.classify)
          exemplary_ids = @json_attrs.fetch('exemplary_image_of', []).pluck('ark_id')
          exemplary_ids.each do |ex_ark_id|
            ex_obj = Curator.digital_object_class.find_by(ark_id: ex_ark_id) ||
                     Curator.collection_class.find_by(ark_id: ex_ark_id)

            raise ActiveRecord::RecordNotSaved, "Bad exemplary id! #{ex_ark_id} is either not in the repo or is not a DigitalObject or Collection" unless ex_obj

            ex_obj.lock!
            build_exemplary(@record) do |exemplary_img|
              exemplary_img.exemplary_object = ex_obj
            end
          end
        end

        build_workflow(@record) do |workflow|
          workflow.send('ingest_origin=', @workflow_json_attrs.fetch(:ingest_origin, ENV['HOME'].to_s))
          processing_state = @workflow_json_attrs.fetch(:processing_state, nil)
          publishing_state = obj&.workflow&.publishing_state
          # set publishing state to same value as parent DigitalObject
          workflow.send('processing_state=', processing_state) if processing_state
          workflow.send('publishing_state=', publishing_state) if publishing_state
        end

        # TODO: set access_edit_group permissions
        build_administrative(@record) do |administrative|
          access_edit_group = nil
          # access_edit_group = @admin_json_attrs.fetch(:access_edit_group, nil)
          administrative.send('access_edit_group=', access_edit_group) if access_edit_group
        end
        @record.save!
      end
      return @success, @result
    end
  end
end
