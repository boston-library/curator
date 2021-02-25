# frozen_string_literal: true

module Curator
  module Mintable
    extend ActiveSupport::Concern

    included do
      include InstanceMethods

      before_validation :generate_ark_id, on: :create

      validates :ark_id, presence: true, uniqueness: true, on: :create
    end
    # Todo put a before validate callback here to the ark manager

    module InstanceMethods
      def ark_params
        Curator.config.default_ark_params.merge({ model_type: self.class.name })
      end

      def generate_ark_id
        self.ark_id = Curator::MinterService.call(ark_params) if ark_id.blank?
      end
    end
  end
end
