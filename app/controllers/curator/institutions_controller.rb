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
      success, institution = Curator::InstitutionFactoryService.call(json_data: institution_params)
      raise ActiveRecord::RecordInvalid.new(institution) if !success

      json_response(serialized_resource(institution), :created)
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
                    :image_thumbnail_300,
                    location: {},
                    metastreams:  { administrative: {}, workflow: {} })
      else
        params
      end
    end
  end
end
