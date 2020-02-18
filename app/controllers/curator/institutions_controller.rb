# frozen_string_literal: true

module Curator
  class InstitutionsController < ApplicationController
    before_action :set_institution, only: [:show, :update]

    # GET /institutions
    def index
      @institutions = Institution.all

      render json: @institutions
    end

    # GET /institutions/1
    def show
      render json: @institution
    end

    # POST /institutions
    def create
      @institution = Institution.new(institution_params)

      if @institution.save
        render json: @institution, status: :created, location: @institution
      else
        render json: @institution.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /institutions/1
    def update
      if @institution.update(institution_params)
        render json: @institution
      else
        render json: @institution.errors, status: :unprocessable_entity
      end
    end

    # # DELETE /institutions/1
    # def destroy
    #   @institution.destroy
    # end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_institution
      @institution = resource_scope.find_by(ark_id: params.fetch())
    end

    # Only allow a trusted parameter "white list" through.
    def institution_params
      params.require(:institution).permit(:ark_id, :name, :url, )
    end
  end
end
