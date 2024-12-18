# frozen_string_literal: true

module Curator
  class ControlledTerms::Geographic < ControlledTerms::Nomenclature
    include ControlledTerms::AuthorityDelegation
    include ControlledTerms::Canonicable
    include ControlledTerms::ReindexDescriptable
    include ControlledTerms::IdFromAuthUniqueValidatable
    include ControlledTerms::IdFromAuthFindable
    include Mappings::MappedTerms

    scope :tgns, -> { with_authority.where(authority: { code: 'tgn' }).references(:authority) }
    scope :geonames, -> { with_authority.where(authority: { code: 'geonames' }).references(:authority) }

    belongs_to :authority, inverse_of: :geographics, class_name: 'Curator::ControlledTerms::Authority', optional: true

    has_many :institution_locations, inverse_of: :location, class_name: 'Curator::Institution', foreign_key: :location_id, dependent: :destroy

    attr_json :area_type, :string
    attr_json :coordinates, :string
    attr_json :bounding_box, :string

    after_update_commit :reindex_associated_institutions

    private

    def reindex_associated_institutions
      institution_locations.find_each(&:queue_indexing_job)
    end
  end
end
