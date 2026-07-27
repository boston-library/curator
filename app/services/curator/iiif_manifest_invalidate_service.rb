# frozen_string_literal: true

module Curator
  class IIIFManifestInvalidateService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.iiif_manifest_url
    self.pool_options = { headers: { 'Content-Type' => 'application/json'  } }.merge(Curator.config.default_remote_service_timeout_opts)
    self.pool_timeout = Curator.config.default_remote_service_pool_opts[:pool_timeout]
    self.pool_size = Curator.config.default_remote_service_pool_opts[:pool_size]

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      begin
        call_invalidate_iiif_manifest!
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
      nil
    end

    protected

    def call_invalidate_iiif_manifest!
      response = with_connection do |conn|
        client.post("/search/#{ark_id}/manifest/cache_invalidate").flush
      end
      raise Curator::Exceptions::RemoteServiceError.new('Failed to trigger manifest purge !', json_response, resp.status) if [200, 404].exclude?(response.code)
      normalize_response!(response.body.to_s)
    end
  end
end
