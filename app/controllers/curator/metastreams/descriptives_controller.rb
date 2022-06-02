# frozen_string_literal: true

module Curator
  class Metastreams::DescriptivesController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource
    include Curator::DescriptiveParams

    before_action :set_descriptive, only: [:show, :update]

    def show
      multi_response(serialized_resource(@descriptive)) if stale?(strong_etag: @descriptive, last_modified: @descriptive.updated_at)
    end

    def update
      success, result = Metastreams::DescriptiveUpdaterService.call(@descriptive, json_data: descriptive_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    def serialized_resource(resource, serializer_params = {})
      adapter_key = @serializer_adapter_key == :xml ? :mods : @serializer_adapter_key
      serializer_class.new(resource, serializer_params, adapter_key: adapter_key || :json).serialize
    rescue StandardError => e
      Rails.logger.error "=======#{e.inspect}======"
      raise Curator::Exceptions::ServerError, "Failed to render serialized resource as #{@serializer_adapter_key}"
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
