# frozen_string_literal: true
module CommonwealthCurator
  class Metastreams::Administrative < ApplicationRecord
    belongs_to :administratable, polymorphic: true, inverse_of: :administrative

    enum description_standard: %w(aacr cco dacs gihc local rda dcrmg amremm dcrmb dcrmc dcrmmss)

    validates :administratable_id, uniqueness: {scope: :administratable_type, allow_nil: true}
  end
end
