# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveUpdaterService < Services::Base
    include Services::UpdaterService

    SIMPLE_ATTRIBUTES_LIST = %i().freeze

    def call
      return @success, @result
    end
  end
end
