# frozen_string_literal: true

module Curator
  module Filestreams
    module IIIFReadyable
      extend ActiveSupport::Concern

      included do
        include InstanceMethods
      end

      module InstanceMethods
        protected

        def remote_service_healthcheck!
          raise Curator::Exceptions::IIIFServerUnavailable if !iiif_server_ready?
        end

        private

        def iiif_server_ready?
          raise StandardError, 'Implement Me'
        end
      end
    end
  end
end