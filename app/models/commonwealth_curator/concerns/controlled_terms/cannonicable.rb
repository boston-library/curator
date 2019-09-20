# frozen_string_literal: true
module CommonwealthCurator
  module Cannonicable
    extend ActiveSupport::Concern
    #Key of the JSON Element where the cannonical label resides in the remote service
    AUTH_LABEL_KEY='http://www.w3.org/2000/01/rdf-schema#label'.freeze
    NOM_LABEL_KEY='http://www.w3.org/2004/02/skos/core#prefLabel'.freeze
    included do
      before_validation :get_canonical_label, if: proc {|c| c.respond_to?(:should_get_cannonical?) && c.should_get_cannonical? }

      private
      def cannonical_format(code)
        case code
        when 'gmgpc', 'lctgm', 'naf', 'lcsh', 'lcgft', 'iso639-2', 'marcrelators', 'resourceTypes'
          '.skos.json'
        when 'aat', 'tgn', 'ulan'
          '.jsonld'
        end
      end
      # def get_canonical_label
      #   if authority_is_getty?
      #     json_path = '.jsonld'
      #     post_fetch = ->(auth_json){
      #       auth_json[NOM_LABEL_KEY] if auth_json[NOM_LABEL_KEY].present?
      #     }
      #   else
      #     json_path = '.skos.json'
      #     post_fetch = ->(auth_json){
      #       label_el = auth_json.collect{|aj| aj[NOM_LABEL_KEY] if aj.key?(NOM_LABEL_KEY)}.compact.flatten.shift
      #       label_el['@value'] if label_el.present?
      #     }
      #   end
      #   self.label = ControlledTerms::RemoteAuthorityService.call(url: value_uri, json_path: json_path, &post_fetch)
      # end
    end
  end
end
