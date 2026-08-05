# frozen_string_literal: true

module Curator
  module Filestreams
    module IIIFServerHealthCheck
      extend ActiveSupport::Concern

      class_methods do
        def ready?
          return true if ENV.fetch('RAILS_ENV', 'development') == 'test'

          begin
            response = with_connection do |connection|
              connection.head('/health')
            end
            response.status.success?
          rescue StandardError => e
            Rails.logger.error "Error: #{name} is not available: #{e.message}"
            false
          end
        end
      end
    end
  end
end