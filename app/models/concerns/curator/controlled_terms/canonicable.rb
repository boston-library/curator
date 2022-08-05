# frozen_string_literal: true

module Curator
  module ControlledTerms
    module Canonicable
      extend ActiveSupport::Concern
      included do
        before_validation :fetch_canonical_label, if: :should_fetch_canonical_label?, on: :create

        protected

        def should_fetch_canonical_label?
          new_record? && label.blank? && value_uri.present?
        end

        def can_query_bpldc?
          authority_code.present? && id_from_auth.present?
        end

        private

        def bpldc_query_path
          return if !can_query_bpldc?

          case authority_code
          when 'aat'
            'fetch/linked_data/getty_aat_ld4l_cache'
          when 'lcgft'
            "show/linked_data/loc_direct/genre/#{id_from_auth}"
          when 'lcsh'
            "show/linked_data/loc_direct/subjects/#{id_from_auth}"
          when 'lctgm', 'gmgpc'
            'search/loc/graphicMaterials'
          when 'naf'
            "show/linked_data/loc_direct/names/#{id_from_auth}"
          when 'tgn'
            "geomash/tgn/#{id_from_auth}"
          when 'geonames'
            "geomash/geonames/#{id_from_auth}"
          when 'ulan'
            'fetch/linked_data/getty_ulan_ld4l_cache'
          end
        end

        def bpldc_query
          return {} if !can_query_bpldc?

          case authority_code
          when 'aat', 'ulan'
            { uri: value_uri }
          when 'lctgm', 'gmgpc'
            { q: id_from_auth }
          else
            {}
          end
        end

        def fetch_canonical_label
          return if bpldc_query_path.blank?

          label_json_block = lambda do |json_body|
            return if json_body.blank?

            el = json_body.is_a?(Array) ? json_body.first : json_body

            return el['label'].join if el['label'].is_a?(Array)

            el['label']
          end

          self.label = ControlledTerms::AuthorityService.call(path: bpldc_query_path, path_prefix: '/qa', query: bpldc_query, &label_json_block)
        end
      end
    end
  end
end
