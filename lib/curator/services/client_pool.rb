# frozen_string_literal: true

module Curator
  module Services
    module ClientPool
      class Registry
        include Singleton

        def initialize
          @_clients = Concurrent::Map.new
        end

        def pool_for(key, &_block)
          _clients.compute_if_absent(key) { yield }
        end

        def pool_keys
          _clients.keys
        end

        def reload_pool(key)
          _clients.compute_if_present(key) do |pool|
            pool.reload { |client| client.close if client }
          end
        end

        def shutdown_pool(key)
          _clients.compute_if_present(key) do |pool|
            pool.shutdown { |client| client.close if client }
          end
        end

        def reload_all_pools!
          _clients.keys.each do |pool_key|
            reload_pool(pool_key)
          end
        end

        def shutdown_and_clear_all_pools!
          _clients.keys.each do |pool_key|
            shutdown_pool(pool_key)
          end
          _clients.clear
        end

        private

        attr_reader :_clients
      end
    end
  end
end
