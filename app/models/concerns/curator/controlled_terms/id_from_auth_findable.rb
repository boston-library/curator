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
          raise MultipleIdFromAuthError, "Multiple results found for #{id_from_auth}!" if jsonb_contains(id_from_auth: id_from_auth).size > 1

          # NOTE: change this to use the #sole method when updating to rails 7
          jsonb_contains(id_from_auth: id_from_auth).first!
        end
      end
    end
  end
end