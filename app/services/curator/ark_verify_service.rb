# frozen_string_literal: true

module Curator
  class ArkVerifyService < Services::Base
    include ArkService

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      call_verify_ark!
    rescue HttpConnectionPool::Error => e
      Rails.logger.error 'HTTP Connection Pool Error!'
      Rails.logger.error "Reason: #{e.message}"
      false
    rescue HTTP::Error => e
      Rails.logger.error 'HTTP Error Occurred Verifying Ark'
      Rails.logger.error "Reason #{e.message}"
      false
    rescue Curator::Exceptions::RemoteServiceError => e
      Rails.logger.error 'Error Occurred Verifying Ark'
      Rails.logger.error "Reason #{e.message}"
      Rails.logger.error "Response code #{e.code}"
      false
    end

    protected

    def call_verify_ark!
      response = with_connection do |conn|
        conn.head("#{self.class.default_path_prefix}/arks/#{ark_id}")
      end
      response.status.success?
    end
  end
end
