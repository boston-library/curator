# frozen_string_literal: true

module Curator
  class Metastreams::DescriptivesController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource
    include Curator::DescriptiveParams

    before_action :set_descriptive, only: [:show, :update]

    def show
      json_response(serialized_resource(@descriptive))
    end

    def update
      success, result = Metastreams::DescriptiveUpdaterService.call(@descriptive, json_data: descriptive_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    private

    def set_descriptive
      @descriptive = @curator_resource.descriptive
    end

    def descriptive_params
      case params[:action]
      when 'update'
        params.require(:descriptive).permit(descriptive_permitted_params('update'))
      else
        params
      end
    end
  end
end
