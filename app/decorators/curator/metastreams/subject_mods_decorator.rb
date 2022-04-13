# frozen_string_literal: true

module Curator
  class Metastreams::SubjectModsDecorator < Decorators::BaseDecorator

    def label
      case __getobj__
      when Curator::ControlledTerms::Subject
        topic_label
      when Curator::ControlledTerms::Name
        name_label
      when Curator::ControlledTerms::Geographic
        geographic_label
      when Curator::DescriptiveFieldSets::Title
        title_label
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
      __getobj__.label if __getobj__.is_a?(Curator::DescriptiveFieldSets::Title)
    end

    def blank?
      return false if __getobj__.blank?

      label.blank? && authority_code.blank? && authority_base_url.blank? && value_uri.blank?
    end
  end
end
