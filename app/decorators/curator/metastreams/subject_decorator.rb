# frozen_string_literal: true

module Curator
  class Metastreams::SubjectDecorator < Decorators::BaseDecorator
    attr_reader :topics, :names, :geos, :other

    def initialize(descriptive)
      @topics = descriptive.subject_topics if descriptive.respond_to?(:subject_topics)
      @names = descriptive.subject_names if descriptive.respond_to?(:subject_names)
      @geos = descriptive.subject_geos if descriptive.respond_to?(:subject_geos)
      @other = descriptive.subject_other if descriptive.respond_to?(:subject_other)
    end

    def blank?
      @topics.blank? && @names.blank? && @geos.blank? && @other.blank?
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
  end
end
