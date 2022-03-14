# frozen_string_literal: true

module Curator
  module Mappings::FindOrCreateHostCollection
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module InstanceMethods
      private

      def find_or_create_host_collection(host_col_name = nil, institution = nil)
        return if host_col_name.blank? || institution.blank?

        institution.host_collections.name_lower(host_col_name).first || institution.host_collections.create!(name: host_col_name)
      end
    end
  end
end
