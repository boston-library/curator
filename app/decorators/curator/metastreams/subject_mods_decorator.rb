# frozen_string_literal: true

module Curator
  class Metastreams::SubjectModsDecorator < Decorators::BaseDecorator
    include Curator::ControlledTerms::NamePartableMods
    # This class delegates and wraps multiple objects for serializing <mods:subject> sub elements

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

    def title_info
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)
    end

    def cartographic
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::DescriptiveFieldSets::Cartographic)
    end

    def temporal_subjects
      return [] if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Array)
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

      return @cartographic_subject = nil if cartographic.blank? && geographic_subject.blank?

      return @cartographic_subject = geographic_subject.cartographic if geographic_subject.present?

      @cartographic_subject = Curator::DescriptiveFieldSets::CartographicModsPresenter.new(projection: cartographic.projection, scale: cartographic.scale)
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

      geographic_subject.label
    end

    def geographic_display_label
      return if geographic_subject.blank?

      geographic_subject.display_label
    end

    def authority_code
      return if __getobj__.is_a?(Curator::ControlledTerms::Name) || __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)

      super if __getobj__.respond_to?(:authority_code)
    end

    def authority_base_url
      return if __getobj__.is_a?(Curator::ControlledTerms::Name) || __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)

      super if __getobj__.respond_to?(:authority_base_url)
    end

    def value_uri
      return if __getobj__.is_a?(Curator::ControlledTerms::Name) || __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)

      super if __getobj__.respond_to?(:value_uri)
    end

    def name_type
      return if name.blank?

      name.name_type
    end

    def hierarchical_geographic
      return if geographic_subject.blank?

      geographic_subject.hierarchical_geographic
    end

    def blank?
      return true if __getobj__.blank?

      name.blank? && topic.blank? && geographic.blank? && cartographic.blank? && other.blank? && temporal_subjects.blank? && title_info.blank?
    end
  end
end
