# frozen_string_literal: true

module Curator
  class Filestreams::IIIFServerCacheInvalidateService < Services::Base
    include Curator::Services::RemoteService
    include Curator::Filestreams::IIIFServerHealthCheck

    self.base_url = Curator.config.iiif_server_url
    self.pool_timeout = Curator.config.default_remote_service_pool_opts[:pool_timeout]
    self.pool_size = Curator.config.default_remote_service_pool_opts[:pool_size]
    self.pool_options = { headers: { 'Accept' => 'application/json',
                                     'Content-Type' => 'application/json',
                                     'Authorization' => "Basic #{basic_auth_encode(Curator.config.iiif_server_credentials[:username], Curator.config.iiif_server_credentials[:secret])}" } }.merge(Curator.config.default_remote_service_timeout_opts)

    attr_reader :ark_id

    # @param Curator::Filestreams::Image#ark_id [String]
    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      call_iiif_api!
    rescue HttpConnectionPool::Error => e
      base_message = 'HTTP Connection Pool Error!'
      json_reason = { 'reason' => e.message }.as_json
      Rails.logger.error base_message
      Rails.logger.error "Reason: #{e.message}"
      raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
    rescue HTTP::Error => e
      base_message = 'HTTP Error Occurred Calling IIIF Server'
      json_reason = { 'reason' => e.message }.as_json
      Rails.logger.error base_message
      Rails.logger.error "Reason: #{e.message}"
      raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
    rescue Oj::Error => e
      base_message = 'Invalid JSON Response From IIIF Server'
      json_reason = { 'reason' => e.message }.as_json
      Rails.logger.error base_message
      Rails.logger.error "Reason: #{e.message}"
      raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
    rescue Curator::Exceptions::RemoteServiceError => e
      Rails.logger.error 'Error Occurred Invalidating IIIF Server Cache'
      Rails.logger.error "Reason: #{e.message}"
      Rails.logger.error "Response code: #{e.code}"
      Rails.logger.error "Response: #{e.json_response}"
      raise
    end

    protected

    def call_iiif_api!
      iiif_payload = {
        verb: 'PurgeItemFromCache',
        identifier: ark_id
      }
      response = with_connection do |conn|
        conn.post('/tasks', json: iiif_payload)
      end

      raise Curator::Exceptions::RemoteServiceError.new('Failed to trigger cache purge in iiif server!', { response: response.to_s }, response.code) if [202, 204].exclude?(response.code)

      { location: response.headers['Location'] }
    end
  end
end
