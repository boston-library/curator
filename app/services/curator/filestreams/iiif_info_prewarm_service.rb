# frozen_string_literal: true

module Curator
  class Filestreams::IIIFInfoPrewarmService < Services::Base
    include Curator::Services::RemoteService
    include Curator::Filestreams::IIIFServerHealthCheck

    self.base_url = Curator.config.iiif_server_url
    self.default_headers = { content_type: 'application/json' }
    self.timeout_options = Curator.config.default_remote_service_timeout_opts.merge(read: 300)

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      begin
        service_response = self.class.with_client do |client|
          call_iiif_info_endpoint(client)
        end

        return service_response
      rescue HTTP::Error => e
        base_message = 'HTTP Error Occurred Calling IIIF Server'
        json_reason = { 'reason' => e.message }.as_json
        Rails.logger.error base_message
        Rails.logger.error "Reason: #{e.message}"
        raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occurred Creating info.json on IIIF Server'
        Rails.logger.error "Reason: #{e.message}"
        Rails.logger.error "Response code: #{e.code}"
        Rails.logger.error "Response: #{e.json_response}"
        raise
      end
      nil
    end

    protected

    def call_iiif_info_endpoint(client)
      info_endpoint = "#{Curator.config.iiif_server_url}/iiif/2/#{ark_id}/info.json"
      resp = client.headers(self.class.default_headers).get(info_endpoint).flush

      return "Successfully created info.json at #{info_endpoint}" if resp.status.success?

      raise Curator::Exceptions::RemoteServiceError.new("Failed to pre warm info for #{ark_id} in iiif server!", { response: resp.body.to_s }, resp.status)
    end
  end
end