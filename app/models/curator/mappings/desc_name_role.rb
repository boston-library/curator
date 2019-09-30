# frozen_string_literal: true
module Curator
  class Mappings::DescNameRole < ApplicationRecord
    belongs_to :descriptive, inverse_of: :name_roles, class_name: Curator.metastreams.descriptive_class.to_s
    belongs_to :name, inverse_of: :descriptive_name_roles, class_name: Curator.controlled_terms.name_class.to_s
    belongs_to :role, inverse_of: :descriptive_name_roles, class_name: Curator.controlled_terms.role_class.to_s

    validate :name_role_class_validator, on: :create


    private
    def name_role_class_validator
      %i(name role).each do |attr|
        class_name = "ControlledTerms::#{attr.to_s.camelize}"
        errors.add(attr, "#{class_name} is not valid!") if self.send(attr).class.to_s != class_name
      end
    end
  end
end
