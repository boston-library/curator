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
      collection = Curator::CollectionFactoryService.call(collection_params)
      json_response(serialized_resource(collection))
    end

    def update
      @curator_resource.touch
      json_response(serialized_resource(@institution))
    end

    private

    def collection_params
      case params[:action]
      when 'create'
        params.require(:collection).permit!
      else
        params
      end
      # TODO: Permit only these
      # :name,
      # :abstract,
      # administrative: [:description_standard, :flagged, :harvestable, :destination_site],
      # workflow:       [:publishing_state, :processing_state, :ingest_origin]
    end
  end
end
