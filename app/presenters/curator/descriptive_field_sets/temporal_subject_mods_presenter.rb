# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::TemporalSubjectModsPresenter
    attr_reader :temporal

    delegate :point, :encoding, to: :date_temporal, allow_nil: true

    def self.wrap_multiple(temporals = [])
      temporals.map(&method(:new))
    end

    def initialize(temporal)
      @temporal = temporal
    end

    def date_temporal
      temporal.is_a?(Curator::DescriptiveFieldSets::DateModsPresenter) ? temporal : nil
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
