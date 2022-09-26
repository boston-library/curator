# frozen_string_literal: true

module Curator
  class IIIFManifestInvalidateService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.iiif_manifest_url
    self.default_path_prefix = '/search'
    self.default_headers = { content_type: 'application/json' }
    self.timeout_options = Curator.config.default_remote_service_timeout_opts

    attr_reader :ark_id

    # @param Curator::DigitalObject#ark_id [String]
    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      begin
        iiif_manifest_response = self.class.with_client do |client|
          call_invalidate_iiif_manifest(client)
        end

        return iiif_manifest_response
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

    def call_invalidate_iiif_manifest(client)
      resp = client.headers(self.class.default_headers).post("#{self.class.default_path_prefix}/#{ark_id}/manifest/cache_invalidate")

      json_response = normalize_response!(resp.body.to_s)
      raise Curator::Exceptions::RemoteServiceError.new('Failed to trigger manifest purge !', json_response, resp.status) if [200, 404].exclude?(resp.status)

      json_response
    end
  end
end
