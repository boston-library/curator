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

        retries = 0
        begin
          return Curator.mappings.host_collection_class.transaction(requires_new: true) do
            institution.host_collections.name_lower(host_col_name).first || institution.host_collections.create!(name: host_col_name)
          end
        rescue ActiveRecord::StaleObjectError => e
          if (retries += 1) <= MAX_RETRIES
            Rails.logger.info 'Record is stale retrying in 2 seconds..'
            sleep(2)
            retry
          else
            Rails.logger.error "=================#{e.inspect}=================="
            raise ActiveRecord::RecordNotSaved, "Max retries reached! caused by: #{e.message}", e.record
          end
        end
      end
    end
  end
end
