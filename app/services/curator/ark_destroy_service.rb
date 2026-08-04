# frozen_string_literal: true

module Curator
  class ArkDestroyService < Services::Base
    include ArkService

    attr_reader :ark_id

    def initialize(ark_id)
      @ark_id = ark_id
    end

    def call
      call_delete_ark!
    rescue HttpConnectionPool::Error => e
      Rails.logger.error 'HTTP Connection Pool Error!'
      Rails.logger.error "Reason: #{e.message}"
      raise ActiveRecord::RecordNotDestroyed, "Error Destroying Ark Due to #{e.inspect}!"
    rescue HTTP::Error => e
      Rails.logger.error 'HTTP Error Occurred Destroying Ark'
      Rails.logger.error "Reason #{e.message}"
      raise ActiveRecord::RecordNotDestroyed, "Error Destroying Ark Due to #{e.inspect}!"
    rescue Oj::Error => e
      Rails.logger.error 'Invalid JSON From Ark Response'
      Rails.logger.error "Reason #{e.message}"
      raise ActiveRecord::RecordNotDestroyed, "Error Destroying Ark Due to #{e.inspect}!"
    rescue Curator::Exceptions::RemoteServiceError => e
      Rails.logger.error 'Error Occurred Destroying Ark'
      Rails.logger.error "Reason #{e.message}"
      Rails.logger.error "Response code #{e.code}"
      Rails.logger.error "Response #{e.json_response}"
      raise ActiveRecord::RecordNotDestroyed, "Error Destroying Ark Due to #{e.inspect}!"
    end

    protected

    def call_delete_ark!
      response = with_connection do |conn|
        conn.delete("#{self.class.default_path_prefix}/arks/#{ark_id}")
      end

      return true if response.status.success?

      if response.code == 404
        Rails.logger.warn "Ark #{ark_id} was not found on destroy! It may have been already destroyed previously"
        return true
      end

      json_response = normalize_response(response.to_s)
      raise Curator::Exceptions::RemoteServiceError.new('Failed to destroy ark in ark-manager-api!', json_response, response.code)
    end
  end
end
