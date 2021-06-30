# frozen_string_literal: true

module Curator
  module Services
    module RemoteService
      extend ActiveSupport::Concern

      class << self
        def client_pool_registry
          ClientPool::Registry.instance
        end
      end

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

          class_attribute :__client_pool, instance_accessor: false, default: Services::RemoteService.client_pool_registry
        end

        class_methods do
          def base_uri
            return @base_uri if defined?(@base_uri)

            @base_uri = Addressable::URI.parse(base_url)
          end

          def with_client
            current_client_pool.with  { |conn| yield conn }
          end

          protected

          def pool_key
            Digest::MD5.hexdigest("#{base_uri.scheme}::#{base_uri.host}::#{base_uri.port}")
          end

          def current_client_pool
            __client_pool.pool_for(pool_key) do
              ConnectionPool.new(pool_options) do
                HTTP.timeout(timeout_options)
                    .persistent(base_uri.normalize.to_s, timeout: 120) # keep-alive timeout
              end
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
              resp = client.head(base_url).flush
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
