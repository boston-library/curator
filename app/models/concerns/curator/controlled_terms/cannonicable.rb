# frozen_string_literal: true

module Curator
  module ControlledTerms
    module Cannonicable
      extend ActiveSupport::Concern
      # Key of the JSON Element where the cannonical label resides in the remote service
      NOM_LABEL_KEY = 'http://www.w3.org/2004/02/skos/core#prefLabel'.freeze
      private_constant :NOM_LABEL_KEY
      included do
        before_validation :fetch_canonical_label, if: :should_fetch_cannonical_label?

        protected

        def should_fetch_cannonical_label?
          self.label.blank? && self.label_required? && self.value_uri.present?
        end

        def label_required?
          self.class.validators.flat_map { |c| c.attributes if c.kind == :presence }.compact.include?(:label)
        end

        private

        def fetch_canonical_label
          label_json_block = case cannonical_json_format
                             when '.jsonld'
                               ->(json_body) { json_body[NOM_LABEL_KEY] if json_body[NOM_LABEL_KEY].present? }
                             when '.skos.json'
                               ->(json_body) {
                                 label_el = json_body.collect { |aj| aj[NOM_LABEL_KEY] if aj.key?(NOM_LABEL_KEY) }.compact.flatten.shift
                                 label_el['@value'] if label_el.present?
                               }
                             else
                               nil
                             end

          unless label_json_block.blank?
            self.label = ControlledTerms::CannonicalLabelService.call(url: value_uri, json_path: cannonical_json_format, &label_json_block)
          end
        end
      end
    end
  end
end
