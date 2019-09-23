# frozen_string_literal: true
module CommonwealthCurator
  class Mappings::DescTermMapping < ApplicationRecord
    default_scope { preload(:mappable) }

    belongs_to :descriptive, inverse_of: :term_mappings, class_name: "CommonwealthCurator::Metastreams::Descriptive", foreign_key: :descriptive_id
    
    belongs_to :mappable, inverse_of: :descriptive_term_mappings, polymorphic: true

    validates :descriptive_id, uniqueness: { scope: [:mappable_id, :mappable_type], allow_nil: true }

    validates :mappable_type, inclusion: { in: CommonwealthCurator::ControlledTerms.nomenclature_types.collect{|type| "CommonwealthCurator::ControlledTerms::#{type}"}, allow_nil: true}

    def mappable=(mappable)
      super
      self.mappable_type = mappable.class.to_s# prevents the base class from being added as the mappable-type
    end
  end
end
