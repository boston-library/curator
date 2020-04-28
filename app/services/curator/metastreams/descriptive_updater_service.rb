# frozen_string_literal: true

module Curator
  class Metastreams::DescriptiveUpdaterService < Services::Base
    include Services::UpdaterService

    UPDATEABLE_ATTRIBUTES = %i().freeze

    def call
      return @success, @result
    end
  end
end
