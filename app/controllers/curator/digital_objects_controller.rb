# frozen_string_literal: true

module Curator
  class DigitalObjectsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource
    include Curator::DescriptiveParams

    # GET /digital_objects
    def index
      digital_objects = resource_scope.order(created_at: :desc).limit(25)
      json_response(serialized_resource(digital_objects))
    end

    # GET /digital_objects/1
    def show
      multi_response(serialized_resource(@curator_resource)) if stale?(strong_etag: @curator_resource, last_modified: @curator_resource.updated_at)
    end

    # POST /digital_objects
    def create
      success, result = Curator::DigitalObjectFactoryService.call(json_data: digital_object_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :created)
    end

    # PATCH/PUT /digital_objects/1
    def update
      success, result = Curator::DigitalObjectUpdaterService.call(@curator_resource, json_data: digital_object_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    def serialized_resource(resource, serializer_params = {})
      adapter_key = @serializer_adapter_key == :xml ? :mods : @serializer_adapter_key
      serializer_class.new(resource, serializer_params, adapter_key: adapter_key || :json).serialize
    rescue StandardError => e
      Rails.logger.error "=======#{e.inspect}======"
      raise Curator::Exceptions::ServerError, "Failed to render serialized resource as #{@serializer_adapter_key}"
    end

    private

    def digital_object_params
      case params[:action]
      when 'create'
        params.require(:digital_object).permit(:ark_id, :created_at, :updated_at,
                                               admin_set: [:ark_id],
                                               is_member_of_collection: [:ark_id],
                                               contained_by: [:ark_id],
                                               metastreams: {
                                                 descriptive: descriptive_permitted_params,
                                                 administrative: [:description_standard, :oai_header_id, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                                 workflow: [:ingest_origin, :publishing_state, :processing_state]
                                               })
      when 'update'
        # NOTE: for collection_members to remove pass in the :id of the mapping object and :_destroy = 1/true to
        # remove and just :ark_id for the collection to add see #should_add_collection_member?/
        # should_remove_collection_member? in /services/digital_object_updater_service.rb
        params.require(:digital_object).permit(is_member_of_collection: [:ark_id, :_destroy], exemplary_file_set: [:ark_id])
      else
        params
      end
    end
  end
end
