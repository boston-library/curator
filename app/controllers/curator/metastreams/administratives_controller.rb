# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativesController < ApplicationController
    include Curator::ResourceClass
    include Curator::ArkResource

    before_action :set_administrative, only: [:show, :update]

    def show
      json_response(serialized_resource(@administrative))
    end

    def update
      @administrative.touch
      json_response(serialized_resource(@administrative))
    end

    private

    def set_administrative
      @administrative = @curator_resource.administrative
    end
  end
end
