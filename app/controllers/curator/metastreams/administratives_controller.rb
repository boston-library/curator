# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativesController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    before_action :set_administrative, only: [:show, :update]

    def show
      json_response(serialized_resource(@administrative))
    end

    def update
      success, result = Metastreams::AdministrativeUpdaterService.call(@administrative, json_data: administrative_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    private

    def set_administrative
      @administrative = @curator_resource.administrative
    end

    def administrative_params
      case params[:action]
      when 'update'
        case @curator_resource&.class&.name&.demodulize&.underscore
        when 'institution'
          params.require(:administrative).permit(destination_site: [], access_edit_group: [])
        when 'collection'
          params.require(:administrative).permit(:harvestable, destination_site: [], access_edit_group: [])
        when 'digital_object'
          params.require(:administrative).permit(:description_standard, :flagged, :harvestable, destination_site: [], access_edit_group: [])
        when 'audio', 'document', 'ereader', 'image', 'metadata', 'text', 'video'
          params.require(:administrative).permit(access_edit_group: [])
        else
          params
        end
      else
        params
      end
    end
  end
end
