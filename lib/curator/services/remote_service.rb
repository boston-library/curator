# frozen_string_literal: true

module Curator
  module Services
    module RemoteService
      extend ActiveSupport::Concern
      
      included do
        include Client
      end

      module Client
        extend ActiveSupport::Concern

        #TODO will require Authorization options once login in system is set up
        included do

          class_attribute :base_url, instance_accessor: false
          class_attribute :pool_options, instance_accessor: false, default: { size: ENV.fetch('RAILS_MAX_THREADS') { 5 }, timeout: 5 }
          class_attribute :timeout_options, instance_accessor: false, default: { connect: 5, write: 5, read: 5 }
          class_attribute :default_headers, instance_accessor: false, default: {}
          class_attribute :default_path_prefix, instance_accessor: false
          class_attribute :ssl_context, instance_accessor: false

          private

          thread_cattr_reader :_client_pool, instance_reader: false
        end

        class_methods do
          def base_uri
            return @base_uri if defined?(@base_uri)

            @base_uri = Addressable::URI.parse(base_url)
          end

          def with_client
            current_client_pool.with { |conn| yield conn }
          end

          protected

          def current_client_pool
            return _client_pool if _client_pool.present?

            Thread.current["attr_#{name}__client_pool"] = ConnectionPool.new(pool_options) do
              HTTP.timeout(timeout_options)
                  .persistent(base_uri.normalize.to_s)
            end
          end
        end
      end

      class_methods do
        def ready?
          # TODO: remove line below once remote services are containerized for CI builds
          # until then, we need this or tons of specs will fail, too many for VCR
          return true if ENV.fetch('RAILS_ENV', 'development') == 'test'

          begin
            with_client do |client|
              resp = client.head(base_url)
              resp.status == 200 ? true : false
            end
          rescue StandardError => e
            Rails.logger.error "Error: BPLDC Authority API is not available: #{e}"
            false
          end
        end
      end
    end
  end
end
