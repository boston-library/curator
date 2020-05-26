# frozen_string_literal: true

module Curator
  module Mappings::TermMappable
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module InstanceMethods

      protected

      def terms_for_subject(subject_attrs = {})
        return [] if subject_attrs.empty?

        terms = []

        subject_attrs.each do |k, v|
          map_type = case k.to_s
                     when 'topics'
                       :subject
                     when 'names'
                       :name
                     when 'geos'
                       :geographic
                     end

          next if map_type.blank?

          terms += v.map do |map_attrs|
                    term_for_mapping(map_attrs,
                                     nomenclature_class: Curator.controlled_terms.public_send("#{map_type}_class"))
          end
        end

        terms
      end

      private

      def term_for_mapping(json_attrs = {}, nomenclature_class:)
        authority_code = json_attrs.fetch(:authority_code, nil)
        term_data = json_attrs.except(:authority_code)
        find_or_create_nomenclature(
          nomenclature_class: nomenclature_class,
          term_data: term_data,
          authority_code: authority_code
        )
      end
    end
  end
end
