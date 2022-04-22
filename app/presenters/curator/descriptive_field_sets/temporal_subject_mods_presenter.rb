# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::TemporalSubjectModsPresenter
    attr_reader :temporal

    def self.wrap_multiple(temporals = [])
      temporals.map(&method(:new))
    end

    def initialize(temporal)
      @temporal = temporal
    end

    def label
      case temporal
      when String
        temporal
      when Curator::DescriptiveFieldSets::DateModsPresenter
        temporal.label
      end
    end
  end
end
