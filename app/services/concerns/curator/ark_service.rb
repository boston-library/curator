# frozen_string_literal: true

module Curator
  module ArkService
    extend ActiveSupport::Concern
    # Ark manager version is v2
    included do
      include Curator::Services::RemoteService

      self.base_url = Curator.config.ark_manager_api_url
      self.default_path_prefix = '/api/v2'
      self.default_headers = { accept: 'application/json', content_type: 'application/json' }
    end
  end
end
