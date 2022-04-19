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

      def ark_identifier
        return if ark_uri.blank?

        ark_ident = Curator::DescriptiveFieldSets::Identifier.new(type: 'uri', label: ark_uri)
        return if !ark_ident.valid?

        ark_ident
      end


      def ark_uri
        return if ark_noid.blank?

        base_uri = Addressable::URI.parse(Curator.config.ark_manager_api_url)
        base_uri.path = "ark:/#{Curator.config.default_ark_params[:namespace_ark]}/#{ark_noid}"
        base_uri.to_s
      end

      def ark_noid
        return if ark_id.blank?

        ark_id.split(':').last
      end

      def ark_params
        Curator.config.default_ark_params.dup.merge({ model_type: self.class.name })
      end
    end
  end
end
