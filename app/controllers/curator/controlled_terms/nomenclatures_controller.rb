# frozen_string_literal: true

module Curator
  class ControlledTerms::NomenclaturesController < ApplicationController
    before_action :set_controlled_terms_nomenclature_type
    before_action :set_controlled_terms_nomenclature, only: [:show, :update]
    # GET /controlled_terms/nomenclatures
    def index
      @controlled_terms_nomenclatures = @controlled_terms_nomenclature_type.all

      render json: @controlled_terms_nomenclatures
    end

    # GET /controlled_terms/nomenclatures/1
    def show
      render json: @controlled_terms_nomenclature
    end

    # POST /controlled_terms/nomenclatures
    def create
      @controlled_terms_nomenclature = @controlled_terms_nomenclature_type.new(controlled_terms_nomenclature_params)

      if @controlled_terms_nomenclature.save
        render json: @controlled_terms_nomenclature, status: :created, location: @controlled_terms_nomenclature
      else
        render json: @controlled_terms_nomenclature.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /controlled_terms/nomenclatures/1
    def update
      if @controlled_terms_nomenclature.update(controlled_terms_nomenclature_params)
        render json: @controlled_terms_nomenclature
      else
        render json: @controlled_terms_nomenclature.errors, status: :unprocessable_entity
      end
    end
    #
    # # DELETE /controlled_terms/nomenclatures/1
    # def destroy
    #   @controlled_terms_nomenclature.destroy
    # end

    private

      # Use callbacks to share common setup or constraints between actions.
      def set_controlled_terms_nomenclature
        @controlled_terms_nomenclature = @controlled_terms_nomenclature_type.find(params[:id])
      end

      def set_controlled_terms_nomenclature_type
        @controlled_terms_nomenclature_type = "Curator::ControlledTerms::#{params[:type]}".constantize
      end

      # Only allow a trusted parameter "white list" through.
      def controlled_terms_nomenclature_params
        params.fetch(:controlled_terms_nomenclature, {})
      end
  end
end
