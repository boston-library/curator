# frozen_string_literal: true

module Curator
  class CollectionsController < ApplicationController
    include Curator::ArkResource

    # GET /collections
    def index
      collections = resource_scope.all
      multi_response(serialized_resource(collections))
    end

    # GET /collections/1
    def show
      multi_response(serialized_resource(@curator_resource))
    end

    # POST /collections
    def create
      @collection = Collection.new(collection_params)

      if @collection.save
        render json: @collection, status: :created, location: @collection
      else
        render json: @collection.errors, status: :unprocessable_entity
      end
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
                                          workflow: [:publishing_state, :processing_state, :ingest_origin]
                                        )
    end
  end
end
