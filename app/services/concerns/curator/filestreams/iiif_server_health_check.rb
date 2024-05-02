# frozen_string_literal: true

module Curator
  module Filestreams
    module IIIFServerHealthCheck
      extend ActiveSupport::Concern

      class_methods do
        def ready?
          return true if ENV.fetch('RAILS_ENV', 'development') == 'test'

          begin
            status = with_client do |client|
              resp = client.headers(default_headers).head('/health').flush
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