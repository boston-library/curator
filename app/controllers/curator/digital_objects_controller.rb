# frozen_string_literal: true

module Curator
  class DigitalObjectsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    # GET /digital_objects
    def index
      digital_objects = resource_scope.order(created_at: :desc).limit(25)
      multi_response(serialized_resource(digital_objects))
    end

    # GET /digital_objects/1
    def show
      multi_response(serialized_resource(@curator_resource))
    end

    # POST /digital_objects
    def create
      success, result = Curator::DigitalObjectFactoryService.call(json_data: digital_object_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :created)
    end

    # PATCH/PUT /digital_objects/1
    def update
      @curator_resource.touch
      json_response(serialized_resource(@curator_resource))
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
                                                 descriptive: {},
                                                               administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                                               workflow: [:ingest_origin, :publishing_state, :processing_state]
                                               })
      when 'update'
        params.require(:digital_object).permit(collection_members: [:ark_id], exemplary_file_set: [:ark_id])
      else
        params
      end
    end
  end
end
