# frozen_string_literal: true

module Curator
  class ArkDestroyService < Services::Base
    include ArkService

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      begin
        call_delete_ark!
      rescue HttpConnectionPool::Error => e
        Rails.logger.error "Connection pool error: #{e.inspect}"
        raise
      rescue HTTP::Error => e
        Rails.logger.error 'HTTP Error Occured Destroying Ark'
        Rails.logger.error "Reason #{e.message}"
        raise ActiveRecord::RecordNotDestroyed, 'Error Destroying Ark!'
      rescue Oj::Error => e
        Rails.logger.error 'Invalid JSON From Ark Response'
        Rails.logger.error "Reason #{e.message}"
        raise ActiveRecord::RecordNotDestroyed, 'Error Destroying Ark!'
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occured Destroying Ark'
        Rails.logger.error "Reason #{e.message}"
        Rails.logger.error "Response code #{e.code}"
        Rails.logger.error "Response #{e.json_response}"
        raise ActiveRecord::RecordNotDestroyed, 'Error Destroying Ark!'
      end
      false
    end

    protected

    def call_delete_ark!
      response = with_connection do |conn|
        conn.delete("/api/v2/arks/#{ark_id}").flush
      end

      return true if response.status.success?

      if response.code == 404
        Rails.logger.warn "Ark #{ark_id} was not found on destroy! It may have been already destroyed previously"
        return true
      end

      json_response = normalize_response(response.body.to_s)
      raise Curator::Exceptions::RemoteServiceError.new('Failed to destroy ark in ark-manager-api!', json_response, response.code)
    end
  end
end
