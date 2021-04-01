# frozen_string_literal: true

module Curator
  class InstitutionsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    # GET /institutions
    def index
      institutions = resource_scope.order(created_at: :desc).limit(25)
      multi_response(serialized_resource(institutions))
    end

    # GET /institutions/1
    def show
      multi_response(serialized_resource(@curator_resource))
    end

    # POST /institutions
    def create
      success, result = Curator::InstitutionFactoryService.call(json_data: institution_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :created)
    end

    # PATCH/PUT /institutions/1
    def update
      success, result = Curator::InstitutionUpdaterService.call(@curator_resource, json_data: institution_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    private

    def institution_params
      case params[:action]
      when 'create'
        params.require(:institution).permit(
                    :ark_id, :created_at, :updated_at, :name, :abstract, :url,
                    files: [:created_at, :file_name, :file_type, :content_type, :byte_size,
                            :checksum_md5, io: [:fedora_content_location], metadata: {}],
                    location: {},
                    metastreams: {
                      administrative: [:description_standard, :hosting_status, :harvestable, :flagged, destination_site: [], access_edit_group: []],
                      workflow: [:ingest_origin, :publishing_state, :processing_state]
                    }
                  )
      when 'update'
        params.require(:institution).permit(:abstract, :url, location: {}, host_collections_attributes: [:id, :name, :_destroy],
                                            files: [:file_name, :file_type, :content_type, :byte_size, :checksum_md5, io: {}, metadata: {}])
      else
        params
      end
    end
  end
end
