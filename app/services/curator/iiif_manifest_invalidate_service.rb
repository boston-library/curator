# frozen_string_literal: true

module Curator
  class IIIFManifestInvalidateService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.iiif_manifest_url
    self.pool_options = { headers: { 'Content-Type' => 'application/json' } }.merge(Curator.config.default_remote_service_timeout_opts)
    self.pool_timeout = Curator.config.default_remote_service_pool_opts[:pool_timeout]
    self.pool_size = Curator.config.default_remote_service_pool_opts[:pool_size]

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      call_invalidate_iiif_manifest!
    rescue HttpConnectionPool::Error => e
      base_message = 'HTTP Connection Pool Error!'
      json_reason = { 'reason' => e.message }.as_json
      Rails.logger.error base_message
      Rails.logger.error "Reason: #{e.message}"
      raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
    rescue HTTP::Error => e
      base_message = 'HTTP Error Occurred Calling IIIF Manifest Invalidate Endpoint!'
      json_reason = { 'reason' => e.message }.as_json
      Rails.logger.error base_message
      Rails.logger.error "Reason: #{e.message}"
      raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
    rescue Oj::Error => e
      base_message = 'Invalid JSON Response From IIIF Manifest Invalidate Endpoint!'
      json_reason = { 'reason' => e.message }.as_json
      Rails.logger.error base_message
      Rails.logger.error "Reason: #{e.message}"
      raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
    rescue Curator::Exceptions::RemoteServiceError => e
      Rails.logger.error 'Error Occurred Invalidating IIIF Manifest!'
      Rails.logger.error "Reason: #{e.message}"
      Rails.logger.error "Response code: #{e.code}"
      Rails.logger.error "Response: #{e.json_response}"
      raise
    end

    protected

    def call_invalidate_iiif_manifest!
      response = with_connection do |conn|
        conn.post("/search/#{ark_id}/manifest/cache_invalidate")
      end

      json_response = normalize_response!(response.to_s)

      raise Curator::Exceptions::RemoteServiceError.new('Failed to trigger manifest purge !', json_response, response.code) if [200, 404].exclude?(response.code)

      json_response
    end
  end
end
