# frozen_string_literal: true

module Curator
  class ControlledTerms::AuthorityService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = "#{ENV['AUTHORITY_API_URL']}"
    self.default_endpoint_prefix = '/bpldc'
    self.default_headers = { accept: 'application/json', content_type: 'application/json'}

    attr_reader :endpoint_path

    def initialize(path:, endpoint_prefix: self.class.default_endpoint_prefix, query: nil)
      @endpoint_path = "#{sendpoint_prefix}/#{path}#{query}".strip
    end

    def call
      begin
        code, body = self.class.client_yielder do |client|
          resp = client.headers(self.class.default_headers).
                        get(endpoint_path)
          [resp.code, resp.body]
        end

        json_response = (200..201).include?(code) ? Oj.load(body) : {}

        return block_given? ? yield(json_response) : json_response
      rescue HTTP::Error => e
        Rails.logger.error "Error Retreiving Json For Authority at #{@url}"
        Rails.logger.error "Reason #{e.message}"
      rescue Oj::Error => e
        Rails.logger.error "Error Parsing Json For Authority at #{@url}"
        Rails.logger.error "Reason #{e.message}"
      end
      nil
    end
  end
end
