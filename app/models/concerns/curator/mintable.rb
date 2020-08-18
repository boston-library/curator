# frozen_string_literal: true

module Curator
  module Mintable
    extend ActiveSupport::Concern

    # TODO: Make this configurable with yaml file or in encrypted secrets/envrionment variables
    DEFAULT_ARK_PARAMS = {
      namespace_ark: '50959',
      namespace_id: 'commonwealth',
      url_base: 'https://digitalcommonwealth.org'
    }.freeze

    included do
      include InstanceMethods

      before_validation :generate_ark_id, on: :create

      validates :ark_id, presence: true, uniqueness: true, on: :create
    end
    # Todo put a before validate callback here to the ark manager

    module InstanceMethods
      def ark_params
        DEFAULT_ARK_PARAMS.dup
      end

      def generate_ark_id
        self.ark_id = Curator::MinterService.call(ark_params) if ark_id.blank?
      end
    end
  end
end
