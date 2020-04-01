# frozen_string_literal: true

module Curator
  module Mintable
    extend ActiveSupport::Concern
    included do
      before_validation :generate_ark_id, on: :create

      validates :ark_id, presence: true, uniqueness: true, on: :create
    end
    # Todo put a before validate callback here to the ark manager

    private

    def generate_ark_id
      self.ark_id = Curator::MinterService.call unless ark_id.present?
    end
  end
end
