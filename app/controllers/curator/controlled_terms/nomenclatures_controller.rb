# frozen_string_literal: true

module Curator
  class ControlledTerms::NomenclaturesController < ApplicationController
    include Curator::ResourceClass

    before_action :set_nomenclature, only: [:show, :update]

    def show
      json_response(serialized_resource(@nomenclature))
    end

    # PATCH/PUT /controlled_terms/nomenclatures/1
    def update
      @nomenclature.touch
      json_response(serialized_resource(@nomenclature))
    end

    private

    def set_nomenclature
      @nomenclature = resource_scope.find(params[:id])
    end

    def nomenclature_params
      # Placeholder for now. need to whitelist params based on type in nested case/when
      case params[:action]
      when 'update'
        params.require(resource_type.to_sym).permit!
      else
        params
      end
    rescue StandardError => e
      Rails.logger.error "===========#{e.inspect}================"
      raise Curator::Exceptions::BadRequest, "Invalid value for for type params", "#{controller_path.dup}/params/:type"
    end
  end
end
