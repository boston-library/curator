# frozen_string_literal: true

module Curator
  class DescSubjectDecorator < Decorators::BaseDecorator
    attr_reader :topics, :name, :geos, :other

    def initialize(descriptive)
      super(descriptive)
      @topics = descriptive.subject_topics if descriptive.respond_to?(:subject_topics)
      @names = descriptive.subject_names if descriptive.respond_to?(:subject_names)
      @geos = descriptive.workflow if descriptive.respond_to?(:subject_geos)
      @other = descriptive.subject_other if descriptive.respond_to?(:subject_other)
    end

    def titles
      other.titles if other
    end

    def temporals
      other.temporals if other
    end

    def dates
      other.dates if dates
    end
  end
end
