# frozen_string_literal: true

module Curator
  class Mappings::DescTerm < ApplicationRecord
    belongs_to :descriptive, inverse_of: :desc_terms, class_name: 'Curator::Metastreams::Descriptive', foreign_key: :descriptive_id

    belongs_to :mappable, inverse_of: :desc_terms, polymorphic: true

    validates :descriptive_id, uniqueness: { scope: [:mappable_id, :mappable_type] }, on: :create

    validates :mappable_type, inclusion: { in: Curator::ControlledTerms.nomenclature_types.collect { |type| "Curator::ControlledTerms::#{type}" } }, on: :create

    def mappable=(mappable)
      super
      self.mappable_type = mappable.class.to_s # prevents the base class from being added as the mappable-type
    end
  end
end
