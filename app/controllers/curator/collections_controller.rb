# frozen_string_literal: true

module Curator
  class CollectionsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    def index
      collections = resource_scope.order(created_at: :desc).limit(25)
      multi_response(serialized_resource(collections))
    end

    def show
      multi_response(serialized_resource(@curator_resource))
    end

    def create
      success, result = Curator::CollectionFactoryService.call(json_data: collection_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :created)
    end

    def update
      success, result = Curator::CollectionUpdaterService.call(@curator_resource, json_data: collection_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    private

    def collection_params
      case params[:action]
      when 'create'
        params.require(:collection).permit(:ark_id, :created_at, :updated_at, :name, :abstract,
                                           institution: [:ark_id],
                                           metastreams: {
                                             administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                                                           workflow: [:ingest_origin, :publishing_state, :processing_state]
                                           })
      when 'update'
        params.require(:collection).permit(:abstract, exemplary_file_set: [:ark_id])
      else
        params
      end
    end
  end
end
