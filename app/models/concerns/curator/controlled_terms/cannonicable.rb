# frozen_string_literal: true

module Curator
  module ControlledTerms
    module Cannonicable
      extend ActiveSupport::Concern
      # Key of the JSON Element where the cannonical label resides in the remote service
      NOM_LABEL_KEY = 'http://www.w3.org/2004/02/skos/core#prefLabel'
      private_constant :NOM_LABEL_KEY
      included do
        before_validation :fetch_canonical_label, if: :should_fetch_cannonical_label?, on: :create

        protected

        def should_fetch_cannonical_label?
          new_record? && label.blank? && value_uri.present?
        end

        private

        def fetch_canonical_label
          label_json_block = case cannonical_json_format
                             when '.skos.json', '.jsonld'
                               lambda { |json_body|
                                 label_el = json_body.flat_map { |aj| aj[NOM_LABEL_KEY].presence }.compact.shift
                                 label_el['@value'] if label_el.present?
                               }
                             end

          self.label = ControlledTerms::CannonicalLabelService.call(url: value_uri, json_path: cannonical_json_format, &label_json_block) if label_json_block.present?
        end
      end
    end
  end
end
