# frozen_string_literal: true

module Curator
  class Mappings::DescNameRole < ApplicationRecord
    belongs_to :descriptive, inverse_of: :name_roles, class_name: 'Curator::Metastreams::Descriptive', touch: true
    belongs_to :name, -> { merge(with_authority) }, inverse_of: :desc_name_roles, class_name: 'Curator::ControlledTerms::Name'
    belongs_to :role, -> { merge(with_authority) }, inverse_of: :desc_name_roles, class_name: 'Curator::ControlledTerms::Role'

    validates :descriptive_id, uniqueness: { scope: [:name_id, :role_id] }
    validate :name_role_class_validator, on: :create

    has_paper_trail on: %i(create destroy update)

    private

    def name_role_class_validator
      %i(name role).each do |attr|
        class_name = "Curator::ControlledTerms::#{attr.to_s.camelize}"
        errors.add(attr, "#{class_name} is not valid!") if send(attr).class.to_s != class_name
      end
    end
  end
end
