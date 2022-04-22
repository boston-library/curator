# frozen_string_literal: true

module Curator
  class Metastreams::SubjectModsDecorator < Decorators::BaseDecorator
    include Curator::ControlledTerms::NamePartableMods

    def self.wrap_multiple(subjects = [])
      subjects.map(&method(:new))
    end

    def name
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::ControlledTerms::Name)
    end

    def geographic
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::ControlledTerms::Geographic)
    end

    def topic
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::ControlledTerms::Subject)
    end

    def title
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)
    end

    def cartographic
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::DescriptiveFieldSets::Cartographic)
    end

    def other
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::DescriptiveFieldSets::Subject)
    end

    def geographic_subject
      return @geographic_subject if defined?(@geographic_subject)

      return @geographic_subject = nil if geographic.blank?

      @geographic_subject = Curator::ControlledTerms::GeographicModsPresenter.new(geographic)
    end

    def cartographic_subject
      return @cartographic_subject if defined?(@cartographic_subject)

      return @cartographic_subject = nil if cartographic.blank? || geographic.blank?

      return @cartographic_subject = geographic.cartographic if geographic.present?

      @cartographic_subject = Curator::DescriptiveFieldSets::CartographicModsPresenter.new(scale: cartographic.scale, projection: cartographic.projection)
    end

    def name_subject
      return @name_subject if defined?(@name_subject)

      return @name_subject = nil if name.blank?

      @name_subject = Curator::Metastreams::SubjectNameModsPresenter.new(name, name_parts)
    end

    def topic_label
      return if topic.blank?

      topic.label
    end

    def geographic_label
      return if geographic_subject.blank?

      geographic_subject.has_hier_geo? ? nil : geographic_subject.label
    end

    def authority_code
      return if __getobj__.is_a?(Curator::ControlledTerms::Name)

      super if __getobj__.respond_to?(:authority_code)
    end

    def authority_base_url
      return if __getobj__.is_a?(Curator::ControlledTerms::Name)

      super if __getobj__.respond_to?(:authority_base_url)
    end

    def value_uri
      return if __getobj__.is_a?(Curator::ControlledTerms::Name)

      super if __getobj__.respond_to?(:value_uri)
    end

    def name_type
      return if name.blank?

      name.name_type
    end

    def hierachical_geographic
      return if geographic_subject.blank?

      geographic_subject.hierarchical_geographic
    end

    def temporals
      other_temporals + date_temporal
    end

    def other_temporals
      return [] if other.blank?

      other.temporals
    end

    def date_temporal
      return @dates if defined?(@dates)

      return @dates = [] if other_dates.blank?

      @dates = other_dates.inject([]) do |ret, date|
        ret += map_date_presenters(date)
        ret
      end
    end

    def other_dates
      return [] if other.blank?

      other.dates
    end

    def blank?
      return true if __getobj__.blank?

      name.blank? && topic.blank? && geographic.blank? && cartographic.blank?
    end

    private

    def map_date_presenters(date)
      date_hash = Curator::Parsers::EdtfDateParser.edtf_date_parser(date: date)
      date_hash = date_hash.except(:type)

      return Array.wrap(Curator::DescriptiveFieldSets::DateModsPresenter.new(**date_hash)) if date_hash[:start].blank? || date_hash[:end].blank?

      [date_hash.dup.except(:end), date_hash.dup.except(:start)].map { |date_attrs| Curator::DescriptiveFieldSets::DateModsPresenter.new(**date_attrs) }
    end
  end
end
