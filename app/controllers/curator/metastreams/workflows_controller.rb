# frozen_string_literal: true

module Curator
  class Metastreams::WorkflowsController < ApplicationController
    before_action :set_workflow
    
    def show
      json_response(serialized_resource(@workflow))
    end

    def update
      json_response(serialized_resource(@workflow))
    end

    private

    def set_workflow
      @workflow = @metastreamble_resource.workflow
    end
  end
end
