# frozen_string_literal: true

module Curator
  module ControlledTerms
    module IdFromAuthFindable
      extend ActiveSupport::Concern

      class MultipleIdFromAuthError < StandardError; end

      class_methods do
        def find_id_from_auth(id_from_auth)
          find_id_from_auth!(id_from_auth)
        rescue MultipleIdFromAuthError
          raise
        rescue ActiveRecord::RecordNotFound
          nil
        end

        def find_id_from_auth!(id_from_auth)
          jsonb_contains(id_from_auth: id_from_auth).sole
        rescue ActiveRecord::SoleRecordExceeded
          raise MultipleIdFromAuthError, "Multiple results found for #{id_from_auth}!"
        rescue ActiveRecord::RecordNotFound
          raise
        end
      end
    end
  end
end