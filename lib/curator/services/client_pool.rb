# frozen_string_literal: true

module Curator
  module Services
    module ClientPool
      class Registry
        include Singleton

        def initialize
          @__clients = Concurrent::Map.new
        end

        def pool_for(key, &block)
          __clients.compute_if_absent(key, &block)
        end

        def pool_keys
          __clients.keys
        end

        def reload_pool(key)
          __clients.compute_if_present(key) do |pool|
            pool.reload { |client| client&.close }
          end
        end

        def shutdown_pool(key)
          __clients.compute_if_present(key) do |pool|
            pool.shutdown { |client| client&.close }
          end
        end

        def reload_all_pools!
          __clients.keys.each do |pool_key|
            reload_pool(pool_key)
          end
        end

        def shutdown_and_clear_all_pools!
          __clients.keys.each do |pool_key|
            shutdown_pool(pool_key)
          end
          __clients.clear
        end

        private

        attr_reader :__clients
      end
    end
  end
end
