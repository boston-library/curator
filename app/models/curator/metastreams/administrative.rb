# frozen_string_literal: true

module Curator
  class Metastreams::Administrative < ApplicationRecord
    belongs_to :administratable, polymorphic: true, inverse_of: :administrative

    enum description_standard: { aacr: 0, cco: 1, dacs: 2, gihc: 3, local: 4, rda: 5, dcrmg: 6, amremm: 7, dcrmb: 8, dcrmc: 9, dcrmmss: 10 }.freeze

    validates :administratable_id, uniqueness: { scope: :administratable_type, allow_nil: true }
  end
end
