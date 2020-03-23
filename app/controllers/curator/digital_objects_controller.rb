# frozen_string_literal: true

module Curator
  class DigitalObjectsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    # GET /digital_objects
    def index
      digital_objects = resource_scope.order(created_at: :desc).limit(25)
      multi_response(serialized_resource(digital_objects))
    end

    # GET /digital_objects/1
    def show
      multi_response(serialized_resource(@curator_resource))
    end

    # POST /digital_objects
    def create
      success, digital_object = Curator::DigitalObjectFactoryService(digital_object_params)
      json_response(serialized_resource(digital_object))
    end

    # PATCH/PUT /digital_objects/1
    def update
      @curator_resource.touch
      json_response(serialized_resource(@curator_resource))
    end

    private

    def digital_object_params
      case params[:action]
      when 'create'
        params.require(:digital_object).permit!
      else
        params
      end
    end
  end
end
