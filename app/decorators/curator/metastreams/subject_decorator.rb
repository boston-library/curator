# frozen_string_literal: true

module Curator
  class Metastreams::SubjectDecorator < Decorators::BaseDecorator
    def topics
      __getobj__.subject_topics if __getobj__.respond_to?(:subject_topics)
    end

    def names
      __getobj__.subject_names if __getobj__.respond_to?(:subject_names)
    end

    def geos
      __getobj__.subject_geos if __getobj__.respond_to?(:subject_geos)
    end

    def other
      __getobj__.subject_other if __getobj__.respond_to?(:subject_other)
    end

    def cartographics
      __getobj__.cartographics if __getobj__.respond_to(:cartographic)
    end

    def titles
      return [] if other.blank?

      other.titles
    end

    def temporals
      return [] if other.blank?

      other.temporals
    end

    def dates
      return [] if other.blank?

      other.dates
    end

    def temporal_mods
      return [] if temporals.blank? && dates.blank?

      tmporals = Curator::DescriptiveFieldSets::TemporalSubjectModsPresenter.wrap_multiple(temporals)

      temporal_presenters = tmporals.inject([]) do |ret, el|
        ret << Array.wrap(el)
        ret
      end

      return temporal_presenters if dates.blank?

      date_temporal_presenters = dates.map { |date| map_date_presenters(date) }.inject([]) do |ret, date_els|
        ret << Curator::DescriptiveFieldSets::TemporalSubjectModsPresenter.wrap_multiple(date_els)
        ret
      end

      temporal_presenters + date_temporal_presenters
    end

    def to_a
      Array.wrap(topics) + Array.wrap(geos) + Array.wrap(names) + Array.wrap(titles) + Array.wrap(temporal_mods)
    end

    def blank?
      return true if __getobj__.blank?

      topics.blank? && names.blank? && geos.blank? && other.blank?
    end

    private

    def map_date_presenters(date)
      date_hash = Curator::Parsers::EdtfDateParser.edtf_date_parser(date: date)
      date_hash = date_hash.except(:type, :qualifier)

      return Array.wrap(Curator::DescriptiveFieldSets::DateModsPresenter.new(**date_hash)) if date_hash[:start].blank? || date_hash[:end].blank?

      [date_hash.dup.except(:end), date_hash.dup.except(:start)].map { |date_attrs| Curator::DescriptiveFieldSets::DateModsPresenter.new(**date_attrs) }
    end
  end
end
