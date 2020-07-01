# frozen_string_literal: true

module Curator
  class Metastreams::SubjectDecorator < Decorators::BaseDecorator
    def topics
      return @topics if defined?(@topics)

      @topics = __getobj__.subject_topics if __getobj__.respond_to?(:subject_topics)
    end

    def names
      return @names if defined?(@names)

      @names = __getobj__.subject_names if __getobj__.respond_to?(:subject_names)
    end

    def geos
      return @geos if defined?(@geos)

      @geos = __getobj__.subject_geos if __getobj__.respond_to?(:subject_geos)
    end

    def other
      return @other if defined?(@other)

      @other = __getobj__.subject_other if __getobj__.respond_to?(:subject_other)
    end

    def titles
      other.titles if other
    end

    def temporals
      other.temporals if other
    end

    def dates
      other.dates if other
    end

    def attributes
      {
        'titles' => titles&.map(&:attributes) || [],
        'temporals' => temporals,
        'dates' => dates
      }
    end

    def blank?
      return true if __getobj__.blank?

      topics.blank? && names.blank? && geos.blank? && other.blank?
    end
  end
end
