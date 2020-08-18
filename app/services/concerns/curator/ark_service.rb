# frozen_string_literal: true

module Curator
  module ArkService
    extend ActiveSupport::Concern
    # Ark manager version is v2
    included do
      include Curator::Services::RemoteService

      self.base_url = "#{ENV['ARK_MANAGER_API_URL']}"
      self.default_endpoint_prefix = '/api/v2'
      self.default_headers = { accept: 'application/json', content_type: 'application/json'}
    end
  end
end
