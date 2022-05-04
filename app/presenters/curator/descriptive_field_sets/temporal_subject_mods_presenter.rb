# frozen_string_literal: true

module Curator
  class DescriptiveFieldSets::TemporalSubjectModsPresenter
    # This class is for serializing <mods:subject><mods:temporal> elements/attributes
    attr_reader :temporal

    delegate :point, :encoding, to: :date_temporal, allow_nil: true

    #
    # @param[optional] temporals [Array[String | Curator::DescriptiveFieldSets::DateModsPresenter]]
    # @return [Array[Curator::DescriptiveFieldSets::TemporalSubjectModsPresenter]]
    def self.wrap_multiple(temporals = [])
      temporals.map(&method(:new))
    end

    #
    # @param[required] temporal [String | Curator::DescriptiveFieldSets::DateModsPresenter]
    # @return [Curator::DescriptiveFieldSets::TemporalSubjectModsPresenter]
    def initialize(temporal)
      @temporal = temporal
    end

    # @return [Curator::DescriptiveFieldSets::DateModsPresenter | nil] - Required for delegating methods to DateModsPresenter
    def date_temporal
      temporal.is_a?(Curator::DescriptiveFieldSets::DateModsPresenter) ? temporal : nil
    end

    # @return [String] - Based on #temporal class
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
