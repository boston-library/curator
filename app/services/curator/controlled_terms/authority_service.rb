# frozen_string_literal: true

module Curator
  class ControlledTerms::AuthorityService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.authority_api_url
    self.default_path_prefix = '/bpldc'
    self.default_headers = { accept: 'application/json', content_type: 'application/json' }

    attr_reader :request_uri

    def initialize(path:, path_prefix: self.class.default_path_prefix, query: {})
      @request_uri = Addressable::URI.parse("#{path_prefix}/#{path}")
      @request_uri.query_values = query if query.present?
    end

    def call
      begin
        bpldc_json = self.class.with_client do |client|
          fetch_auth_data(client)
        end

        return block_given? ? yield(bpldc_json) : bpldc_json
      rescue HTTP::Error => e
        Rails.logger.error "Error Retreiving Json For Authority at #{@request_uri}"
        Rails.logger.error "Reason #{e.message}"
      rescue Oj::Error => e
        Rails.logger.error "Error Parsing Json For Authority at #{@request_uri}"
        Rails.logger.error "Reason #{e.message}"
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error "Error Retreiving Json For Authority at #{@request_uri}"
        Rails.logger.error "Reason #{e.message}"
      end
      nil
    end

    protected

    def fetch_auth_data(client)
      resp = client.headers(self.class.default_headers).get(request_uri.to_s).flush
      json_response = Oj.load(resp.body.to_s)
      raise Curator::Exceptions::RemoteServiceError.new('Failed to retrieve data from bpldc_auth_api!',
                                                        json_response, resp.status) if !resp.status.success?

      json_response
    end
  end
end
