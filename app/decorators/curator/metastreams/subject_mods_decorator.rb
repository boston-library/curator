# frozen_string_literal: true

module Curator
  class Metastreams::SubjectModsDecorator < Decorators::BaseDecorator

    def self.wrap_multiple(subjects = [])
      subjects.map(&:new)
    end

    def label
      case __getobj__
      when Curator::ControlledTerms::Subject
        topic.label
      when Curator::ControlledTerms::Name
        name.label
      when Curator::ControlledTerms::Geographic
        geographic.label
      when Curator::DescriptiveFieldSets::Title
        title.label
      when String
        __getobj__
      end
    end

    def authority_code
      super if __getobj__.respond_to?(:authority_code)
    end

    def authority_base_url
      super if __getobj__.respond_to?(:authority_base_url)
    end

    def value_uri
      super if __getobj__.respond_to?(:value_uri)
    end

    def name
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::ControlledTerms::Name)
    end

    def topic
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::ControlledTerms::Subject)
    end

    def geographic
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::ControlledTerms::Geographic)
    end

    def title
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)
    end

    def cartographic
      return if __getobj__.blank?

      __getobj__ if __getobj__.is_a?(Curator::DescriptiveFieldSets::Cartographic)
    end


    def topic_label
      __getobj__.label if __getobj__.is_a?(Curator::ControlledTerms::Subject)
    end

    def name_label
      __getobj__.label if __getobj__.is_a?(Curator::ControlledTerms::Name)
    end

    def geographic_label
      __getobj__.label if __getobj__.is_a?(Curator::ControlledTerms::Geographic)
    end

    def title_label
      __getobj__.label
    end

    def blank?
      return true if __getobj__.blank?

      label.blank? && authority_code.blank? && authority_base_url.blank? && value_uri.blank?
    end
  end
end
