# frozen_string_literal: true

module Curator
  module ArkService
    extend ActiveSupport::Concern
    # Ark manager version is v2
    included do
      include Curator::Services::RemoteService

      self.base_url = Curator.config.ark_manager_api_url
      self.pool_timeout = Curator.config.default_remote_service_pool_opts[:pool_timeout]
      self.pool_size = Curator.config.default_remote_service_pool_opts[:pool_size]
      self.pool_options = { headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }.merge(Curator.config.default_remote_service_timeout_opts)
      self.default_path_prefix = '/api/v2'
    end
  end
end
