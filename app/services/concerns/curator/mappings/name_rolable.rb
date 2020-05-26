# frozen_string_literal: true

module Curator
  module Mappings::NameRolable
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module InstanceMethods
      private

      def name_role(name_attrs = {}, role_attrs = {})
        {
          name: find_or_create_nomenclature(
            nomenclature_class: Curator.controlled_terms.name_class,
            term_data: name_attrs.except(:authority_code),
            authority_code: name_attrs.fetch(:authority_code, nil)
          ),
          role: find_or_create_nomenclature(
            nomenclature_class: Curator.controlled_terms.role_class,
            term_data: role_attrs.except(:authority_code),
            authority_code: role_attrs.fetch(:authority_code, nil)
          )
        }
      end
    end
  end
end
