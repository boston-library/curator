# frozen_string_literal: true

module Curator
  class ControlledTerms::GenreModsDecorator < Decorators::BaseDecorator
    def self.wrap_multiple(genres = [])
      genres.map(&method(:new))
    end

    def label
      super if __getobj__.respond_to?(:label)
    end

    def authority
      __getobj__.authority_code if __getobj__.respond_to?(:authority_code)
    end

    def authority_uri
      __getobj__.authority_base_url if __getobj__.respond_to?(:authority_base_url)
    end

    def value_uri
      super if __getobj__.respond_to?(:value_uri)
    end

    def display_label
      return if __getobj__.blank? || !__getobj__.respond_to?(:basic?)

      __getobj__.basic? ? 'general' : 'specific'
    end

    def blank?
      return true if __getobj__.blank?

      label.blank? && authority.blank? && authority_uri.blank? && value_uri.blank? && display_label.blank?
    end
  end
end
