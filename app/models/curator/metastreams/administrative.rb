# frozen_string_literal: true

module Curator
  class Metastreams::Administrative < ApplicationRecord
    belongs_to :administratable, polymorphic: true, inverse_of: :administrative, touch: true

    VALID_DESTINATION_SITES = %w(bpl commonwealth nblmc argo).freeze
    VALID_FLAGGED_VALUES = %w(explicit offensive).freeze

    enum description_standard: { aacr: 0, cco: 1, dacs: 2, gihc: 3, local: 4, rda: 5, dcrmg: 6, amremm: 7, dcrmb: 8,
                                 dcrmc: 9, dcrmmss: 10, appm: 11, dcrmm: 12 }.freeze
    enum hosting_status: { hosted: 0, harvested: 1 }.freeze

    validates :hosting_status, presence: true
    validates :oai_header_id, uniqueness: { allow_nil: true, allow_blank: true }
    validates :administratable_id, uniqueness: { scope: :administratable_type }
    validates :administratable_type, inclusion: { in: Metastreams.valid_base_types + Metastreams.valid_filestream_types }
    validates :flagged, inclusion: { in: VALID_FLAGGED_VALUES }, allow_nil: true

    validate :validate_destination_site

    has_paper_trail if: proc { |a| [Curator.digital_object_class.name, Curator::Filestreams::FileSet.name].include?(a.administratable_type) }

    scope :local_id_finder, -> (oai_header_id) { where.not(oai_header_id: nil).where(oai_header_id: oai_header_id) }

    def oai_object?
      oai_header_id?
    end

    private

    def validate_destination_site
      errors.add(:destination_site, 'value is not an Array') if !destination_site.is_a?(Array)

      errors.add(:destination_site, "#{destination_site} does not include #{VALID_DESTINATION_SITES.join(' ,')}") if destination_site.any? { |ds| !VALID_DESTINATION_SITES.include?(ds) }

      errors.add(:destination_site, 'values in destination_site are not uniq') if VALID_DESTINATION_SITES.any? { |vds| destination_site.count(vds) > 1 }
    end
  end
end
