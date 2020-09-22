# frozen_string_literal: true

module Curator
  class Metastreams::Administrative < ApplicationRecord
    belongs_to :administratable, polymorphic: true, inverse_of: :administrative, touch: true

    VALID_DESTINATION_SITES = %w(bpl commonwealth nblmc).freeze

    enum description_standard: { aacr: 0, cco: 1, dacs: 2, gihc: 3, local: 4, rda: 5, dcrmg: 6, amremm: 7, dcrmb: 8, dcrmc: 9, dcrmmss: 10, appm: 11 }.freeze
    enum hosting_status: { hosted: 0, harvested: 1 }.freeze

    validates :hosting_status, presence: true
    validates :oai_header_id, uniqueness: { allow_nil: true, allow_blank: true }
    validates :administratable_id, uniqueness: { scope: :administratable_type }
    validates :administratable_type, inclusion: { in: Metastreams.valid_base_types + Metastreams.valid_filestream_types }

    validate :validate_destination_site

    private

    def validate_destination_site
      errors.add(:destination_site, 'value is not an Array') if !destination_site.is_a?(Array)

      errors.add(:destination_site, "#{destination_site} does not include #{VALID_DESTINATION_SITES.join(' ,')}") if destination_site.any? { |ds| !VALID_DESTINATION_SITES.include?(ds) }

      errors.add(:destination_site, 'values in destination_site are not uniq') if VALID_DESTINATION_SITES.any? { |vds| destination_site.count(vds) > 1 }
    end
  end
end
