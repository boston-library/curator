# frozen_string_literal: true

module Curator
  class Filestreams::FileSetsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    def index
      file_sets = resource_scope.order(created_at: :desc).limit(25)
      multi_response(serialized_resource(file_sets))
    end

    def show
      multi_response(serialized_resource(@curator_resource))
    end

    def create
      file_set = Curator::FileSetFactoryService.call(file_set_params)
      json_response(serialized_resource(file_set))
    end

    def update
      @curator_resource.touch
      json_response(serialized_resource(@curator_resource))
    end

    private

    def file_set_params
      # Placeholder for now. need to whitelist params based on type in case/when
      case params[:action]
      when 'create'
        params.require(resource_type.to_sym).permit!
      else
        params
      end
    rescue StandardError => e
      Rails.logger.error "===========#{e.inspect}================"
      raise Curator::Exceptions::BadRequest, 'Invalid value for for type params', "#{controller_path.dup}/params/:type"
    end
  end
end
