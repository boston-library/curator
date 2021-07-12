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
        ark_json = self.class.with_client do |client|
          generate_ark(client)
        end

        return ark_json.dig('ark', 'pid')
      rescue HTTP::Error => e
        Rails.logger.error 'HTTP Error Occured Generating Ark'
        Rails.logger.error "Reason #{e.message}"
        raise ActiveRecord::RecordNotSaved, 'Error Generating Ark!'
      rescue Oj::Error => e
        Rails.logger.error 'Invalid JSON From Ark Response'
        Rails.logger.error "Reason #{e.message}"
        raise ActiveRecord::RecordNotSaved, 'Error Generating Ark!'
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occured Generating Ark'
        Rails.logger.error "Reason #{e.message}"
        Rails.logger.error "Response code #{e.code}"
        Rails.logger.error "Response #{e.json_response}"
        raise ActiveRecord::RecordNotSaved, 'Error Generating Ark!'
      end
      false
    end

    protected

    def generate_ark(client)
      resp = client.headers(self.class.default_headers).
               post("#{self.class.default_path_prefix}/arks", json: ark_create_params).flush

      json_response = Oj.load(resp.body.to_s)

      raise Curator::Exceptions::RemoteServiceError.new('Failed to mint ark from ark-manager-api!', json_response, resp.status) if !resp.status.success?

      json_response
    end
  end
end
