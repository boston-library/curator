# frozen_string_literal: true

module Curator::Middleware
  class ArkOrIdConstraint
    ID_REGEX = /\d+/
    ARK_REGEX = /\A[a-z]+.*[a-z]*:{1}[a-z0-9]{9}\z/

    attr_reader :pattern

    def initialize
      @pattern = Regexp.union(ID_REGEX, ARK_REGEX).freeze
    end

    def matches?(request)
      identifier = request.params[:id].to_s
      pattern.match?(identifier)
    end
  end
end
