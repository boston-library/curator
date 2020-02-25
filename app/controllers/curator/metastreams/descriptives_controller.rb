# frozen_string_literal: true

module Curator
  class Metastreams::DescriptivesController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    before_action :set_descriptive, only: [:show, :update]

    def show
      json_response(serialized_resource(@descriptive))
    end

    def update
      @descriptive.touch
      json_response(serialized_resource(@descriptive))
    end

    private

    def set_descriptive
      @descriptive = @curator_resource.descriptive
    end
  end
end
