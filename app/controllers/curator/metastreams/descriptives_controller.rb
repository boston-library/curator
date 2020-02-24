# frozen_string_literal: true

module Curator
  class Metastreams::DescriptivesController < ApplicationController
    include Curator::MetastreamableResource

    before_action :set_descriptive

    def show
      json_response(serialized_resource(@descriptive))
    end

    def update
      @descriptive.touch
      json_response(serialized_resource(@descriptive))
    end

    private

    def set_descriptive
      @descriptive = @metastreamble_resource.descriptive
    end
  end
end
