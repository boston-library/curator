# frozen_string_literal: true

module Curator
  module Mintable
    extend ActiveSupport::Concern
    included do
      before_validation :generate_ark_id, on: :create, unless: :has_ark_id?

      validates :ark_id, presence: true, uniqueness: true, on: :create
    end
    # Todo put a before validate callback here to the ark manager

    def has_ark_id?
      ark_id.present?
    end

    private

    def generate_ark_id
      self.ark_id = Curator::MinterService.call
    end
  end
end
