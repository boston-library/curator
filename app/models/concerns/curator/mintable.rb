# frozen_string_literal: true

module Curator
  module Mintable
    extend ActiveSupport::Concern
    included do
      before_validation :generate_ark_id, on: :create, if: proc { |m| m.ark_id.blank? }

      validates :ark_id, presence: true, uniqueness: { allow_nil: true }
    end
    # Todo put a before validate callback here to the ark manager

    private

    def generate_ark_id
      self.ark_id = Curator::MinterService.call
    end
  end
end
