# frozen_string_literal: true

module Curator::Middleware
  module RouteConsts
    JSON_CONSTRAINT = ->(request) { request.format.symbol == :json }
    XML_CONSTRAINT = ->(request) { %i(xml mods).include?(request.format.symbol) }
    NOMENCLATURE_TYPES = Curator.controlled_terms.nomenclature_types.map(&:underscore).freeze
    FILE_SET_TYPES = Curator.filestreams.file_set_types.map(&:downcase).freeze
  end
end
