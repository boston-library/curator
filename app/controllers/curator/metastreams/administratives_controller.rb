# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativesController < ApplicationController
    include Curator::MetastreamableResource

    before_action :set_administrative

    def show
      json_response(serialized_resource(@administrative))
    end

    def update
      @administrative.touch
      json_response(serialized_resource(@administrative))
    end

    private

    def set_administrative
      @administrative = @metastreamble_resource.administrative
    end
  end
end
