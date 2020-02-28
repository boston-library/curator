# frozen_string_literal: true

module Curator
  module ArkResource
    extend ActiveSupport::Concern

    included do
      before_action :set_curator_resource, only: [:show, :update]
    end

    protected

    def set_curator_resource
      @curator_resource = resource_scope.find_by(ark_id: params[:id]) || resource_scope.find(params[:id])
    end
  end
end
