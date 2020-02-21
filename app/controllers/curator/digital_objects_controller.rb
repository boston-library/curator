# frozen_string_literal: true

module Curator
  class DigitalObjectsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    # GET /digital_objects
    def index
      digital_objects = resource_scope.limit(50)
      multi_response(serialized_resource(digital_objects))
    end

    # GET /digital_objects/1
    def show
      multi_response(serialized_resource(@curator_resource))
    end

    # POST /digital_objects
    def create
      digital_object = Curator::DigitalObjectFactoryService(digital_object_params)
      json_response(serialized_resource(digital_object))
      # if @digital_object.save
      #   render json: @digital_object, status: :created, location: @digital_object
      # else
      #   render json: @digital_object.errors, status: :unprocessable_entity
      # end
    end

    # PATCH/PUT /digital_objects/1
    def update
      @curator_resource.touch
      json_response(serialized_resource(@curator_resource))
    end

    # DELETE /digital_objects/1
    # def destroy
    #   @digital_object.destroy
    # end

    private

    # Use callbacks to share common setup or constraints between actions.
    # def set_digital_object
    #   @digital_object = DigitalObject.find(params[:id])
    # end

    # Only allow a trusted parameter "white list" through.

    def digital_object_params
      params.require(:digital_object)
    end
  end
end
