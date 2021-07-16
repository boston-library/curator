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
        return self.class.with_client do |client|
          verify_ark(client)
        end
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

    def verify_ark(client)
      resp = client.headers(self.class.default_headers).head("#{self.class.default_path_prefix}/arks/#{ark_id}").flush
      resp.code == 200
    end
  end
end
