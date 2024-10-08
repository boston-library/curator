# frozen_string_literal: true

module Curator
  class Filestreams::IIIFServerCacheInvalidateService < Services::Base
    include Curator::Services::RemoteService
    include Curator::Filestreams::IIIFServerHealthCheck

    self.base_url = Curator.config.iiif_server_url
    self.default_headers = { content_type: 'application/json' }
    self.timeout_options = Curator.config.default_remote_service_timeout_opts

    attr_reader :ark_id

    # @param Curator::Filestreams::Image#ark_id [String]
    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      begin
        iiif_response = self.class.with_client do |client|
          call_iiif_api(client)
        end

        return iiif_response
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
      nil
    end

    protected

    def call_iiif_api(client)
      auth_payload = {
        user: Curator.config.iiif_server_credentials[:username],
        pass: Curator.config.iiif_server_credentials[:secret]
      }

      iiif_payload = {
        verb: 'PurgeItemFromCache',
        identifier: ark_id
      }

      resp = client.basic_auth(auth_payload).headers(self.class.default_headers).post('/tasks', json: iiif_payload).flush

      raise Curator::Exceptions::RemoteServiceError.new('Failed to trigger cache purge in iiif server!', { response: resp.body.to_s }, resp.status) if [202, 204].exclude?(resp.status)

      { location: resp.headers['Location'] }
    end
  end
end
