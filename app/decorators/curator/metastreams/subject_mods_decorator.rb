# frozen_string_literal: true

module Curator
  class Metastreams::SubjectModsDecorator < Decorators::BaseDecorator
    include Curator::ControlledTerms::NamePartableMods
    # DESCRIPTION: This class delegates and wraps multiple objects for serializing the various <mods:subject> sub elements
    # Curator::Metastreams::SubjectModsDecorator#initialize
    ## @param obj [Curator::ControlledTerms::Name | Curator::ControlledTerms::Geographic | Curator::ControlledTerms::Subject | Curator::DescriptiveFieldSets::Title | Curator::DescriptiveFieldSets::Cartographic | Curator::DescriptiveFieldSets::Subject |  Array[Curator::DescriptiveFieldSets::TemporalSubjectModsPresenter]]]
    ## @return [Curator::ControlledTerms::SubjectModsDecorator] instance
    ## USAGE:
    ### NOTE: The preferred usage in serializer is to use wrap_multiple method in conjunction with the SubjectDecorator#to_a method(see #to_a method in ./subject_decorator.rb)
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### subject_mods = Curator::Metastreams::SubjectModsDecorator.wrap_multiple(desc.subject.to_a)
    #
    # @param subjects [Array[Curator::ControlledTerms::Name | Curator::ControlledTerms::Geographic | Curator::ControlledTerms::Subject | Curator::DescriptiveFieldSets::Title | Curator::DescriptiveFieldSets::Cartographic | Curator::DescriptiveFieldSets::Subject |  Array[Curator::DescriptiveFieldSets::TemporalSubjectModsPresenter]]]
    # @return [Array[Curator::Metastreams::SubjectModsDecorator]
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

    # @return [Curator::ControlledTerms::GeographicModsPresenter | nil] - Used for <mods:subject> with geographic sub elements
    def geographic_subject
      return @geographic_subject if defined?(@geographic_subject)

      return @geographic_subject = nil if geographic.blank?

      @geographic_subject = Curator::ControlledTerms::GeographicModsPresenter.new(geographic)
    end

    # @return [Curator::ControlledTerms::GeographicModsPresenter | nil] - Used for <mods:subject><mods:cartographic> sub elements
    def cartographic_subject
      return @cartographic_subject if defined?(@cartographic_subject)

      return @cartographic_subject = nil if cartographic.blank? && geographic_subject.blank?

      return @cartographic_subject = geographic_subject.cartographic if geographic_subject.present?

      @cartographic_subject = Curator::DescriptiveFieldSets::CartographicModsPresenter.new(projection: cartographic.projection, scale: cartographic.scale)
    end

    # @return [Curator::Metastreams::SubjectNameModsPresenter] - Used for <mods:subject><mods:name> sub elements
    def name_subject
      return @name_subject if defined?(@name_subject)

      return @name_subject = nil if name.blank?

      @name_subject = Curator::Metastreams::SubjectNameModsPresenter.new(name, name_parts)
    end

    # @return [String] - Used for getting the value for <mods:subject><mods:topic> sub elements
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

    # @return [String] - Used for getting the <mods:subject authority=''> attribute value. Retunrs nil if decorator object is a Name or Title
    def authority_code
      return if __getobj__.is_a?(Curator::ControlledTerms::Name) || __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)

      super if __getobj__.respond_to?(:authority_code)
    end

    # @return [String] - Used for getting the <mods:subject authorityURI=''> attribute value. Returns nil if decorator object is a Name or Title
    def authority_base_url
      return if __getobj__.is_a?(Curator::ControlledTerms::Name) || __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)

      super if __getobj__.respond_to?(:authority_base_url)
    end

    # @return [String] - Used for getting the <mods:subject valueURI=''> attribute value. Returns nil if decorator object is a Name or Title
    def value_uri
      return if __getobj__.is_a?(Curator::ControlledTerms::Name) || __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)

      super if __getobj__.respond_to?(:value_uri)
    end

    # @return [String] - Used for getting the <mods:subject><mods:name type=''> attribute value.
    def name_type
      return if name.blank?

      name.name_type
    end

    # @return [Curator::ControlledTerms::GeographicModsPresenter::TgnHierGeo | nil] - Used for <mods:subject><mods:hierarchicalGeographic> sub elements
    def hierarchical_geographic
      return if geographic_subject.blank?

      geographic_subject.hierarchical_geographic
    end

    # @return [Boolean] - Needed for mods serializer due to decorator complexity
    def blank?
      return true if __getobj__.blank?

      name.blank? && topic.blank? && geographic.blank? && cartographic.blank? && other.blank? && temporal_subjects.blank? && title_info.blank?
    end
  end
end
