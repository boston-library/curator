# frozen_string_literal: true

module Curator
  class ControlledTerms::AuthoritiesController < ApplicationController
    before_action :set_controlled_terms_authority, only: [:show, :update]

    # GET /controlled_terms/authorities
    def index
      @controlled_terms_authorities = ControlledTerms::Authority.all

      render json: @controlled_terms_authorities
    end

    # GET /controlled_terms/authorities/1
    def show
      render json: @controlled_terms_authority
    end

    # POST /controlled_terms/authorities
    def create
      @controlled_terms_authority = ControlledTerms::Authority.new(controlled_terms_authority_params)

      if @controlled_terms_authority.save
        render json: @controlled_terms_authority, status: :created, location: @controlled_terms_authority
      else
        render json: @controlled_terms_authority.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /controlled_terms/authorities/1
    def update
      if @controlled_terms_authority.update(controlled_terms_authority_params)
        render json: @controlled_terms_authority
      else
        render json: @controlled_terms_authority.errors, status: :unprocessable_entity
      end
    end

    private

      # Use callbacks to share common setup or constraints between actions.
      def set_controlled_terms_authority
        @controlled_terms_authority = ControlledTerms::Authority.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def controlled_terms_authority_params
        def authority_params
          params.require(:authority).permit(:code, :base_url, :label)
        end
      end
  end
end
