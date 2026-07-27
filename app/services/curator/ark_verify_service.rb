# frozen_string_literal: true

module Curator
  class ArkVerifyService < Services::Base
    include ArkService

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      begin
        call_verify_ark!
      rescue HttpConnectionPool::Error => e
        Rails.logger.error "Connection pool error: #{e.inspect}"
        raise
      rescue HTTP::Error => e
        Rails.logger.error 'HTTP Error Occured Verifying Ark'
        Rails.logger.error "Reason #{e.message}"
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occured Verifying Ark'
        Rails.logger.error "Reason #{e.message}"
        Rails.logger.error "Response code #{e.code}"
      end
      false
    end

    protected

    def call_verify_ark!
      response = with_connection do |conn|
        conn.head("/api/v2/arks/#{ark_id}").flush
      end
      response.status.success?
    end
  end
end
