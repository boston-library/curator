# frozen_string_literal: true

module Curator
  class Metastreams::WorkflowsController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    before_action :set_workflow, only: [:show, :update]

    def show
      json_response(serialized_resource(@workflow))
    end

    def update
      json_response(serialized_resource(@workflow))
    end

    private

    def set_workflow
      @workflow = @curator_resource.workflow
    end
  end
end
