# frozen_string_literal: true

module Curator
  class MintableCallbacks
    # NOTE: This class is based off https://guides.rubyonrails.org/active_record_callbacks.html#callback-classes
    # NOTE: per this answer https://github.com/rails/rails/issues/33192#issuecomment-399869375 throw(:abort) only works in before_* callbacks  after_* callbacks should raise ActiveRecord::RecordInvalid or some other ActiveRecord Error
    def self.before_validation(mintable)
      begin
        return if mintable.ark_id.present?

        mintable.ark_id = mint_new_ark(mintable)
      rescue Curator::Exceptions::ArkManagerApiUnavailable => e
        mintable.errors.add(:ark_id, e.message)
        throw(:abort)
      end
    end

    # TODO: Refactor factories and fixtures so we can actually test this
    def self.after_validation(mintable)
      begin
        return if Rails.env.test? || ark_exists?(mintable.ark_id)

        mintable_ark = mint_new_ark(mintable)

        return if mintable.ark_id == mintable_ark

        mintable.errors.add(:ark_id, "Imported ark with #{mintable.ark_id}, Got #{mintable_ark} when attempting to re-mint with the following ark_params\n #{mintable.ark_params.inspect}")
        raise ActiveRecord::RecordInvalid, mintable
      rescue Curator::Exceptions::ArkManagerApiUnavailable => e
        mintable.errors.add(:ark_id, e.message)
        raise ActiveRecord::RecordInvalid, mintable
      end
    end

    # NOTE: only use for after_destroy_commit

    def self.after_commit(mintable)
      Curator::ArkDestroyJob.perform_later(mintable.ark_id)
    end

    class << self
      protected

      def ark_exists?(ark_id)
        return false if ark_id.blank?

        raise Curator::Exceptions::ArkManagerApiUnavailable if !verification_service_ready?

        Curator::ArkVerifyService.call(ark_id)
      end

      def mint_new_ark(mintable)
        raise Curator::Exceptions::ArkManagerApiUnavailable if !minter_service_ready?

        Curator::MinterService.call(mintable.ark_params)
      end

      private

      def minter_service_ready?
        Curator::MinterService.ready?
      end

      def verification_service_ready?
        Curator::ArkVerifyService.ready?
      end
    end
  end
end
