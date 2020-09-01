# frozen_string_literal: true

module Curator
  class ControlledTerms::AuthorityService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = "#{ENV['AUTHORITY_API_URL']}"
    self.default_path_prefix = '/bpldc'
    self.default_headers = { accept: 'application/json', content_type: 'application/json'}

    attr_reader :url_path

    def initialize(path:, path_prefix: self.class.default_path_prefix, query: nil)
      @url_path = "#{path_prefix}/#{path}#{query}".strip
    end

    def call
      begin
        code, body = get_response


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

    protected

    def get_response
      self.class.with_client do |client|
        resp = client.headers(self.class.default_headers).
                      get(url_path)
        [resp.code, resp.body]
      end
    end
  end
end
