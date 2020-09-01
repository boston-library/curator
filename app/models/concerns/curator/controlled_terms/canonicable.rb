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

        private

        def bpldc_path
          return if authority.blank? || id_from_auth.blank?

          case self.class.name.demodulize
          when 'Genre'
            basic ? nil : 'basic_genres'
          when 'ResourceType'
            'resource_types'
          when 'Geographic'
            "geomash/#{authority_code}/#{id_from_auth}"
          when 'Languages'
            'languages'
          when 'Roles'
            'roles'
          else
            nil
          end
        end


        def fetch_canonical_label
          return if bpldc_path.blank?

          label_json_block =
          case self.class.name.demodulize
          when 'Geographic'
            ->(json_body) { json_body['label'] if json_body.present? }
          else
            lambda do |json_body|
              return if json_body.blank?

              el = json_body.select { |nom| nom['id_from_auth'] == id_from_auth }
              el['label']
            end
          end

          self.label = ControlledTerms::AuthorityService.call(path: bpldc_path,
                                                              &label_json_block)
        end
      end
    end
  end
end
