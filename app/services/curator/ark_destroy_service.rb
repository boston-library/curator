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
        return self.class.with_client do |client|
          delete_ark(client)
        end
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

    def delete_ark(client)
      resp = client.headers(self.class.default_headers).delete("#{self.class.default_path_prefix}/arks/#{ark_id}").flush

      return true if resp.status.success?

      if resp.code == 404
        Rails.logger.warn "Ark #{ark_id} was not found on destroy! It may have been already destroyed previously"
        return true
      end

      json_response = normalize_response(resp.body.to_s)
      raise Curator::Exceptions::RemoteServiceError.new('Failed to destroy ark in ark-manager-api!', json_response, resp.status)
    end
  end
end
