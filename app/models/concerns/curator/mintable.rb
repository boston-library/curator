# frozen_string_literal: true

module Curator
  module Mintable
    extend ActiveSupport::Concern

    class_methods do
      def find_ark(ark_id)
        find_ark!(ark_id)
      rescue ActiveRecord::RecordNotFound
        nil
      end

      def find_ark!(ark_id)
        find_by!(ark_id: ark_id)
      end
    end

    included do
      include InstanceMethods

      before_validation Curator::MintableCallbacks, on: :create
      after_validation Curator::MintableCallbacks, on: :create

      validates :ark_id, presence: true, uniqueness: true, on: :create

      after_destroy_commit Curator::MintableCallbacks
    end

    module InstanceMethods
      def ark_identifier
        return @ark_identifier if defined?(@ark_identifier)

        return @ark_identifier = nil if self.class.name != 'Curator::DigitalObject' || ark_uri.blank?

        ark_ident = Curator::DescriptiveFieldSets::Identifier.new(type: 'uri', label: ark_uri)

        return @ark_identifier = nil if !ark_ident.valid?

        @ark_identifier = ark_ident
      end

      def ark_iiif_manifest_identifier
        return @ark_iiif_manifest_identifier if defined?(@ark_iiif_manifest_identifier)

        return @ark_iiif_manifest_identifier = nil if self.class.name != 'Curator::DigitalObject' || ark_uri.blank? || is_harvested?

        return @ark_iiif_manifest_identifier = nil if respond_to?(:image_file_sets) && image_file_sets.blank?

        ark_iiif_ident = Curator::DescriptiveFieldSets::Identifier.new(type: 'iiif-manifest', label: "#{ark_uri}/manifest")

        return @ark_iiif_manifest_identifier = nil if !ark_iiif_ident.valid?

        @ark_iiif_manifest_identifier = ark_iiif_ident
      end

      def ark_preview_identifier
        return @ark_preview_identifier if defined?(@ark_preview_identifier)

        return @ark_preview_identifier = nil if self.class.name != 'Curator::DigitalObject' || ark_uri.blank?

        return @ark_preview_identifier = nil if is_harvested? && respond_to?(:metadata_file_sets) && metadata_file_sets.with_attached_image_thumbnail_300.all? { |fs| !fs.image_thumbnail_300.uploaded? }

        ark_preview_ident = Curator::DescriptiveFieldSets::Identifier.new(type: 'uri-preview', label: "#{ark_uri}/thumbnail")

        return @ark_preview_identifier = nil if !ark_preview_ident.valid?

        @ark_preview_identifier = ark_preview_ident
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
