# frozen_string_literal: true

module Curator
  class CollectionsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    # GET /collections
    def index
      collections = resource_scope.limit(50)
      multi_response(serialized_resource(collections))
    end

    # GET /collections/1
    def show
      multi_response(serialized_resource(@curator_resource))
    end

    # POST /collections
    def create
      collection = Curator::CollectionFactoryService.call(collection_create_params)
      json_response(serialized_resource(collection))
    end

    # PATCH/PUT /collections/1
    def update
      @curator_resource.touch
      json_response(serialized_resource(@institution))
    end

    # DELETE /collections/1
    # def destroy
    #   @collection.destroy
    # end

    private

    # Only allow a trusted parameter "white list" through.
    def collection_create_params
      params.require(:collection).permit(:ark_id,
                                         :name,
                                         :abstract,
                                          administrative: [:description_standard, :flagged, :harvestable, :destination_site],
                                          workflow:       [:publishing_state, :processing_state, :ingest_origin])
    end
  end
end
