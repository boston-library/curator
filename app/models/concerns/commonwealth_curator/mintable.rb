# frozen_string_literal: true
module CommonwealthCurator
  module Mintable
    extend ActiveSupport::Concern
    included do
      before_validation :generate_ark_id, on: :create

      validates :ark_id, presence: true, uniqueness: { allow_nil: true }
    end
    #Todo put a before validate callback here to the ark manager
    private
    def generate_ark_id
      self.ark_id = "bpl-#{SecureRandom.hex(6)}" #Temporary workaround until ark manager is finsished
    end
  end
end
