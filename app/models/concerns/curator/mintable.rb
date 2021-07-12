# frozen_string_literal: true

module Curator
  module Mintable
    extend ActiveSupport::Concern

    included do
      include InstanceMethods

      before_validation :generate_ark_id, on: :create

      validates :ark_id, presence: true, uniqueness: true, on: :create

      after_destroy_commit :destroy_ark
    end

    module InstanceMethods
      def ark_params
        Curator.config.default_ark_params.dup.merge({ model_type: self.class.name })
      end
      # rubocop:disable Metrics/LineLength
      # TODO: We should validate the arks have actual entries in the ark manager database on on create. Otherwise the permalink urls will be broken. As well as the the other functionalities the ark manager provides. I'm currently holding off until we are done testing but ideally we should implment this check once we are ready for the migration on prod. Also we should add an after_destroy commit that "deletes" the ark entries. This won't actually delet them since they will just be flagged as actuve = false. Ideally we should put this in a background job.
      # rubocop:enable Metrics/LineLength

      def destroy_ark
        Curator::ArkDeleteJob.perform_later(ark_id)
      end

      def generate_ark_id
        return if ark_id.present?

        minter_service_available = Curator::MinterService.ready?

        raise Curator::Exceptions::ArkManagerApiUnavailable if !minter_service_available

        self.ark_id = Curator::MinterService.call(ark_params)
      end
    end
  end
end
