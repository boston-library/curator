# frozen_string_literal: true

module Curator
  module ControlledTerms
    module Canonicable
      extend ActiveSupport::Concern
      # Key of the JSON Element where the canonical label resides in the remote service
      # NOM_LABEL_KEY = 'http://www.w3.org/2004/02/skos/core#prefLabel'
      # private_constant :NOM_LABEL_KEY
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
            '/fetch/linked_data/getty_aat_ld4l_cache'
          when 'lcgft'
            '/fetch/linked_data/locgenres_ld4l_cache'
          when 'lcsh'
            "/show/linked_data/loc/subjects/#{id_from_auth}"
          when 'lctgm', 'gmgpc'
            '/search/loc/graphicMaterials'
          when 'marcgt'
            '/search/loc/genreFormSchemes/marcgt'
          when 'naf'
            '/fetch/linked_data/locnames_ld4l_cache'
          when 'tgn'
            '/fetch/linked_data/getty_tgn_ld4l_cache'
          when 'geonames'
            '/fetch/linked_data/geonames_direct'
          when 'ulan'
            '/fetch/linked_data/getty_ulan_ld4l_cache'
          end
        end

        def bpldc_query
          return {} if !can_query_bpldc?

          case authority_code
          when 'aat', 'lcgft', 'naf', 'ulan', 'tgn', 'geonames'
            { uri: value_uri }
          when 'marcgt', 'lctgm', 'gmgpc'
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
