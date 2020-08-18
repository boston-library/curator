# frozen_string_literal: true

module Curator
  module Services
    module RemoteService

      extend ActiveSupport::Concern

      # NOTE: do not inherit sub classes from this

      included do
        include Client
      end

      module Client
        extend ActiveSupport::Concern

        #TODO will require Authorization options once login in sstem is set up
        included do
          class_attribute :base_url, instance_accessor: false
          class_attribute :pool_options, instance_accessor: false, default: { size: ENV.fetch('RAILS_MAX_THREADS') { 5 }, timeout: 5 }
          class_attribute :timeout_options, instance_accessor: false, default: { connect: 5, write: 5, read: 5 }
          class_attribute :default_headers, instance_accessor: false, default: {}
          class_attribute :default_endpoint_prefix, instance_accessor: false
          class_attribute :ssl_context, instance_accessor: false
        end

        class_methods do
          def base_uri
            return @base_uri if defined?(@base_uri)

            @base_uri = Addressable::URI.parse(base_url)
          end

          def client_yielder
            client_pool.with { |conn| yield conn }
          end

          protected

          def client_pool
            return @client_pool if defined?(@client_pool)

            @client_pool = ConnectionPool.new(pool_options) do
              HTTP.timeout(timeout_options)
                  .persistent(base_uri.normalize.to_s)
            end
          end
        end
      end
    end
  end
end
