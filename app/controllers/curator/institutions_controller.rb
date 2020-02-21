# frozen_string_literal: true

module Curator
  class InstitutionsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    # GET /institutions
    def index
      institutions = resource_scope.limit(50)
      multi_response(serialized_resource(institutions))
    end

    # GET /institutions/1
    def show
      multi_response(serialized_resource(@curator_resource))
    end

    # POST /institutions
    def create
      institution = Curator::InstitutionFactoryService.call(institution_create_params)
      json_response(serialized_resource(institution))
    end

    # PATCH/PUT /institutions/1
    def update
      @curator_resource.touch # NOTE: TEMPORARY until we make an updater service
      json_response(serialized_resource(@curator_resource))
    end

    # # DELETE /institutions/1
    # def destroy
    #   @institution.destroy
    # end

    private

    # Only allow a trusted parameter "white list" through.
    def institution_create_params
      params.require(:institution).permit(:ark_id,
                                          :name,
                                          :url,
                                          :abstract,
                                          :image_thumbnail_300,
                                          location:       [:area_type, :coordinates, :bounding_box, :authority_code, :label, :id_from_auth],
                                          administrative: [:description_standard, :flagged, :harvestable, :destination_site],
                                          workflow:       [:publishing_state, :processing_state, :ingest_origin])
    end
  end
end
