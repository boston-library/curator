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
      Rails.logger.info workflow_params.awesome_inspect
      success, result = Metastreams::WorkflowUpdaterService.call(@workflow, json_data: workflow_params)

      raise_failure(result) unless success

      json_response(serialized_resource(result), :ok)
    end

    private

    def set_workflow
      @workflow = @curator_resource.workflow
    end

    def workflow_params
      case params[:action]
      when 'update'
        Rails.logger.info @curator_resource&.class&.name&.demodulize&.underscore.awesome_inspect
        case @curator_resource&.class&.name&.demodulize&.underscore
        when 'institution', 'collection', 'digital_object'
          params.require(:workflow).permit(:publishing_state)
        when 'audio', 'document', 'ereader', 'image', 'metadata', 'text', 'video'
          params.require(:workflow).permit(:processing_state)
        end
      else
        params
      end
    end
  end
end
