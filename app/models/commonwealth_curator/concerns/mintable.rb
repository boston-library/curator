# frozen_string_literal: true
module CommonwealthCurator
  module Mintable
    validates :ark_id, presence: true, uniqueness: { allow_nil: true }
    #Todo put a before validate callback here to the ark manager
  end
end
