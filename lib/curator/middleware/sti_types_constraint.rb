# frozen_string_literal: true

module Curator::Middleware
  class StiTypesConstraint
    attr_reader :sti_type_matcher

    def initialize(types = [])
      @sti_type_matcher = Regexp.union(types).freeze
    end

    def matches?(request)
      type = request.params[:type]
      sti_type_matcher.match?(type)
    end
  end
end
