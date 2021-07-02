# frozen_string_literal: true

module Curator
  module Services
    module RemoteService
      extend ActiveSupport::Concern

      class << self
        def current_client_pool_for(key, &block)
          previous_val = Thread.current[:current_client_pool_for]
          Thread.current[:current_client_pool_for] = __client_pools.pool_for(key, &block)
        ensure
          Thread.current[:current_client_pool_for] = previous_val
        end

        def reload!
          __client_pools.reload_all_pools!
        ensure
          Thread.current[:current_client_pool_for] = nil
        end

        def clear!
          __client_pools.shutdown_and_clear_all_pools!
        ensure
          Thread.current[:client_pool_registry] = nil
        end

        private

        def __client_pools
          Thread.current[:client_pool_registry] ||= ClientPool::Registry.instance
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
        end

        class_methods do
          def base_uri
            return @base_uri if defined?(@base_uri)

            @base_uri = Addressable::URI.parse(base_url)
          end

          def with_client
            __current_client_pool.with { |conn| yield conn }
          end

          protected

          def pool_key
            return @pool_key if defined?(@pool_key)

            @pool_key = Digest::MD5.hexdigest("#{base_uri.scheme}::#{base_uri.host}::#{base_uri.port}")
          end

          def __current_client_pool
            Services::RemoteService.current_client_pool_for(pool_key) do
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
            status = with_client do |client|
              resp = client.headers(default_headers).head('/').flush
              resp.status
            end
            status == 200
          rescue StandardError => e
            Rails.logger.error "Error: #{name} is not available: #{e.message}"
            false
          end
        end
      end
    end
  end
end
