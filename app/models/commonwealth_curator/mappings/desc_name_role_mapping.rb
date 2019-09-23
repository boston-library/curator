# frozen_string_literal: true
module CommonwealthCurator
  class Mappings::DescNameRoleMapping < ApplicationRecord
    default_scope { includes(:name, :role) }
    belongs_to :descriptive, inverse_of: :name_roles, class_name: 'CommonwealthCurator::Metastreams::Descriptive'
    belongs_to :name, inverse_of: :descriptive_name_roles, class_name: 'CommonwealthCurator::ControlledTerms::Name'
    belongs_to :role, inverse_of: :descriptive_name_roles, class_name: 'CommonwealthCurator::ControlledTerms::Role'

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
end
