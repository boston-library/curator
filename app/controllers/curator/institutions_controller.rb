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
      success, institution = Curator::InstitutionFactoryService.call(institution_params)

      raise ActiveRecord::RecordInvalid.new(institution) if !successa

      json_response(serialized_resource(institution))
    end

    # PATCH/PUT /institutions/1
    def update
      @curator_resource.touch # NOTE: TEMPORARY until we make an updater service
      json_response(serialized_resource(@curator_resource))
    end

    private

    def institution_params
      case params[:action]
      when 'create'
        params.require(:institution).permit(
                    :ark_id, :created_at, :updated_at, :name, :abstract, :url,
                    :location => [:label, :authority_code, :id_from_auth, :coordinates, :area_type, :bounding_box ],
                    :metastreams => [:administrative => [:destination_site, :description_standard, :hosting_status, :harvestable, :flagged],
                    :workflow => [:ingest_origin, :publishing_state, :processing_state]])
      else
        params
      end
    end
  end
end
