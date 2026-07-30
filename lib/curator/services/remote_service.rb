# frozen_string_literal: true

module Curator
  module Services
    module RemoteService
      extend ActiveSupport::Concern

      included do
        include HttpConnectionPool::Connectable
        include ResponseNormalizer

        class_attribute :default_path_prefix
      end

      module ResponseNormalizer
        extend ActiveSupport::Concern

        private

        def normalize_response(json_response_body)
          normalize_response!(json_response_body)
        rescue
          {}
        end

        def normalize_response!(json_response_body)
          Oj.load(json_response_body, mode: :rails, time_format: :ruby, hash_class: ActiveSupport::HashWithIndifferentAccess, omit_nil: true)
        end
      end

      class_methods do
        def ready?
          # TODO: remove line below once remote services are containerized for CI builds
          # until then, we need this or tons of specs will fail, too many for VCR
          return true if ENV.fetch('RAILS_ENV', 'development') == 'test'

          begin
            response = with_connection do |conn|
              conn.head('/')
            end

            response.status.success?
          rescue StandardError => e
            Rails.logger.error "Error: #{name} is not available: #{e.message}"
            false
          end
        end

        def basic_auth_encode(user, pass)
          Base64.strict_encode64("#{user}:#{pass}")
        end
      end
    end
  end
end
