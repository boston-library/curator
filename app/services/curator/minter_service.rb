# frozen_string_literal: true

module Curator
  class MinterService < Services::Base
    include ArkService

    attr_reader :ark_create_params

    def initialize(ark_params = {})
      @ark_create_params = { 'ark' => ark_params }
    end

    def call
      begin
        ark_json = call_generate_ark!
        ark_json.dig('ark', 'pid')
      rescue HttpConnectionPool::Error => e
        Rails.logger.error "Connection pool error: #{e.inspect}"
        raise
      rescue HTTP::Error => e
        Rails.logger.error 'HTTP Error Occured Generating Ark'
        Rails.logger.error "Reason #{e.message}"
      rescue Oj::Error => e
        Rails.logger.error 'Invalid JSON From Ark Response'
        Rails.logger.error "Reason #{e.message}"
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occured Generating Ark'
        Rails.logger.error "Reason #{e.message}"
        Rails.logger.error "Response code #{e.code}"
        Rails.logger.error "Response #{e.json_response}"
      end
      nil
    end

    protected

    def call_generate_ark!
      response = with_connection do |conn|
        conn.post("/api/v2/arks", json: ark_create_params).flush
      end

      json_response = normalize_response!(response.body.to_s)

      raise Curator::Exceptions::RemoteServiceError.new('Failed to mint ark from ark-manager-api!', json_response, response.code) unless response.status.success?

      json_response
    end
  end
end
