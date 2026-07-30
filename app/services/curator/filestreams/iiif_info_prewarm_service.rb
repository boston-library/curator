# frozen_string_literal: true

module Curator
  class Filestreams::IIIFInfoPrewarmService < Services::Base
    include Curator::Services::RemoteService
    include Curator::Filestreams::IIIFServerHealthCheck

    self.base_url = Curator.config.iiif_server_url
    self.pool_timeout = Curator.config.default_remote_service_pool_opts[:pool_timeout]
    self.pool_size = Curator.config.default_remote_service_pool_opts[:pool_size]
    self.pool_options = { headers: { 'Content-Type' => 'application/json' } }.merge(Curator.config.default_remote_service_timeout_opts)

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      begin
        return call_iiif_info_endpoint!
      rescue HttpConnectionPool::Error => e
        Rails.logger.error "Connection pool error: #{e.inspect}"
        raise
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

    def call_iiif_info_endpoint!
      info_endpoint = "/iiif/2/#{ark_id}/info.json"

      response = with_connection do |conn|
        conn.get(info_endpoint)
      end

      return "Successfully created info.json at #{info_endpoint}" if response.status.success?

      raise Curator::Exceptions::RemoteServiceError.new("Failed to pre warm info for #{ark_id} in iiif server!", { response: response.to_s }, response.code)
    end
  end
end