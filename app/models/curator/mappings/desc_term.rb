# frozen_string_literal: true

module Curator
  class Mappings::DescTerm < ApplicationRecord

    belongs_to :descriptive, inverse_of: :desc_terms, class_name: Curator.metastreams.descriptive_class_name, foreign_key: :descriptive_id

    belongs_to :mappable, inverse_of: :desc_terms, polymorphic: true

    validates :descriptive_id, uniqueness: { scope: [:mappable_id, :mappable_type], allow_nil: true }

    validates :mappable_type, inclusion: { in: Curator.controlled_terms.nomenclature_types.collect{|type| "Curator::ControlledTerms::#{type}"}, allow_nil: true}

    def mappable=(mappable)
      super
      self.mappable_type = mappable.class.to_s# prevents the base class from being added as the mappable-type
    end
  end
end
