# frozen_string_literal: true

module Curator
  class Metastreams::SubjectDecorator < Decorators::BaseDecorator
    # DESCRIPTION: This class acts as a wrapper for a Curator::Metastreams::Descriptive in order for usage in both mods and json serialization
    # NOTE: There is an instance method on Curator::Metastreams::Descriptive that instantiates this decorator
    # SubjectDecorator#initialize
    ## @param obj
    ## @return [Curator::Metastreams::SubjectDecorator]
    ## USAGE(JSON):
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### subject_other = Curator::Metastreams::SubjectDecorator.new(desc) OR desc.subject
    ## USAGE(MODS):
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### subjects = Curator::Metastreams::SubjectDecorator.new(desc).to_a OR desc.subject.to_a
    ### subject_mods = Curator::Metastreams::SubjectModsDecorator.wrap_multiple(subjects)

    # @return [ActiveRecord::Relation[Curator::ControlledTerms::Subject]]
    def topics
      __getobj__.subject_topics if __getobj__.respond_to?(:subject_topics)
    end

    # @return [ActiveRecord::Relation[Curator::ControlledTerms::Name]]
    def names
      __getobj__.subject_names if __getobj__.respond_to?(:subject_names)
    end

    # @return [ActiveRecord::Relation[Curator::ControlledTerms::Geographic]]
    def geos
      __getobj__.subject_geos if __getobj__.respond_to?(:subject_geos)
    end

    # @return [Curator::DescriptiveFieldSets::Subject]
    def other
      __getobj__.subject_other if __getobj__.respond_to?(:subject_other)
    end

    # @return [Array[Curator::DescriptiveFieldSets::Cartographic]]
    def cartographics
      __getobj__.cartographics if __getobj__.respond_to(:cartographic)
    end

    # @return [Array[Curator::DescriptiveFieldSets::Title]]
    def titles
      return [] if other.blank?

      other.titles
    end

    # @return [Array[String]]
    def temporals
      return [] if other.blank?

      other.temporals
    end

    # @return [Array[String]]
    def dates
      return [] if other.blank?

      other.dates
    end

    # @return [Array[Curator::DescriptiveFieldSets::TemporalSubjectModsPresenter]]
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

    # @return Array[Misc] - This method is used to wrap all the subject relations in an array and pass to the SubjectModsDecorator.wrap_multiple class method.
    def to_a
      Array.wrap(topics) + Array.wrap(geos) + Array.wrap(names) + Array.wrap(titles) + Array.wrap(temporal_mods)
    end

    # @return [Boolean] - Needed for json and mods serializers
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
