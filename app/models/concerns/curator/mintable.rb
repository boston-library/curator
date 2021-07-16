# frozen_string_literal: true

module Curator
  module Mintable
    extend ActiveSupport::Concern

    included do
      include InstanceMethods

      before_validation Curator::MintableCallbacks, on: :create
      after_validation Curator::MintableCallbacks, on: :create

      validates :ark_id, presence: true, uniqueness: true, on: :create

      after_destroy_commit Curator::MintableCallbacks
    end

    module InstanceMethods
      def ark_params
        Curator.config.default_ark_params.dup.merge({ model_type: self.class.name })
      end
    end
  end
end
