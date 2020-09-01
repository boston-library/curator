# frozen_string_literal: true

module Curator
  class MinterService < Services::Base
    include ArkService

    attr_reader :ark_create_params

    def initialize(ark_params = {})
      @ark_create_params = ark_params
      @ark = nil
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
        raise 'Error Generating Ark!'
      rescue Oj::Error => e
        Rails.logger.error "Invalid JSON From Ark Response"
        Rails.logger.error "Reason #{e.message}"
        raise 'Error Generating Ark!'
      rescue => e
        Rails.logger.error 'Error Occured Generating Ark'
        Rails.logger.error "Reason #{e.message}"
        raise 'Error Generating Ark!'
      end
    end

    protected

    def generate_ark(client)
      resp = client.headers(self.class.default_headers).
               post("#{self.class.default_path_prefix}/arks", json: ark_create_params)

      json_response = Oj.load(resp.body.to_s)

      raise json_response.inspect if !resp.status.success?

      json_response
    end
  end
end
