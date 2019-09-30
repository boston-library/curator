# frozen_string_literal: true
module Curator
  class DigitalObjectsController < ApplicationController
    before_action :set_digital_object, only: [:show, :update, :destroy]

    # GET /digital_objects
    def index
      @digital_objects = DigitalObject.all

      render json: @digital_objects
    end

    # GET /digital_objects/1
    def show
      render json: @digital_object
    end

    # POST /digital_objects
    def create
      @digital_object = DigitalObject.new(digital_object_params)

      if @digital_object.save
        render json: @digital_object, status: :created, location: @digital_object
      else
        render json: @digital_object.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /digital_objects/1
    def update
      if @digital_object.update(digital_object_params)
        render json: @digital_object
      else
        render json: @digital_object.errors, status: :unprocessable_entity
      end
    end

    # DELETE /digital_objects/1
    def destroy
      @digital_object.destroy
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_digital_object
        @digital_object = DigitalObject.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def digital_object_params
        params.fetch(:digital_object, {})
      end
  end
end
