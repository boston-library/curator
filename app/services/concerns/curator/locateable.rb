# frozen_string_literal: true

module Curator
  module Locateable
    extend ActiveSupport::Concern

    protected

    def location_object(json_attrs = {})
      find_or_create_nomenclature(
        nomenclature_class: Curator.controlled_terms.geographic_class,
        term_data: json_attrs.except(:authority_code),
        authority_code: json_attrs.fetch(:authority_code, nil)
      )  
    end
  end
end
