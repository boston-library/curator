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

    def to_a
      Array.wrap(topics) + Array.wrap(geos) + Array.wrap(names) + Array.wrap(titles) + Array.wrap(temporals) + Array.wrap(dates)
    end

    def blank?
      return true if __getobj__.blank?

      topics.blank? && names.blank? && geos.blank? && other.blank?
    end
  end
end
