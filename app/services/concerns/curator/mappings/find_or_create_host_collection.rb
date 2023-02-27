# frozen_string_literal: true

module Curator
  module Mappings::FindOrCreateHostCollection
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module InstanceMethods
      protected

      # @param host_col_name [String]
      # @param institution [Curator::Institution]
      # @return [Curator::Mappings::HostCollection]
      def find_or_create_host_collection(host_col_name = nil, institution = nil)
        return if host_col_name.blank? || institution.blank?

        find_host_collection(host_col_name, institution) || create_host_collection!(host_col_name, institution)
      end

      private

      # @param host_col_name [String]
      # @param institution [Curator::Institution]
      # @return [Curator::Mappings::HostCollection | NilClass]
      def find_host_collection(host_col_name, institution)
        institution.host_collections.name_lower(host_col_name).first
      end

      # @param host_col_name [String]
      # @param institution [Curator::Institution]
      # @return [Curator::Mappings::HostCollection]
      def create_host_collection!(host_col_name, institution)
        institution.host_collections.create!(name: host_col_name)
      end
    end
  end
end
