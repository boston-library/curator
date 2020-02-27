# frozen_string_literal: true

module Curator
  class ControlledTerms::AuthoritiesController < ApplicationController
    include Curator::ResourceClass

    def index
      authorities = resource_scope.order(name: :desc)
      json_response(serialized_resource(authorities))
    end
  end
end
