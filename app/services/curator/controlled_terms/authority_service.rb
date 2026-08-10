# frozen_string_literal: true

module Curator
  class ControlledTerms::AuthorityService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.authority_api_url
    self.pool_options = { headers: { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }.merge(Curator.config.default_remote_service_timeout_opts)
    self.pool_timeout = Curator.config.default_remote_service_pool_opts[:pool_timeout]
    self.pool_size = Curator.config.default_remote_service_pool_opts[:pool_size]
    self.default_path_prefix = '/bpldc'

    attr_reader :request_uri

    def initialize(path:, path_prefix: self.class.default_path_prefix, query: {})
      @request_uri = Addressable::URI.parse("#{path_prefix}/#{path}")
      @request_uri.query_values = query if query.present?
    end

    def call
      bpldc_json = call_fetch_auth_data!

      return bpldc_json unless block_given?

      yield(bpldc_json)
    rescue HttpConnectionPool::Error => e
      Rails.logger.error 'HTTP Connection Pool Error!'
      Rails.logger.error "Reason: #{e.message}"
      nil
    rescue HTTP::Error => e
      Rails.logger.error "Error Retrieving Json for Authority at #{request_uri}"
      Rails.logger.error "Reason: #{e.message}"
      nil
    rescue Oj::Error => e
      Rails.logger.error "Error Parsing Json for Authority at #{request_uri}"
      Rails.logger.error "Reason: #{e.message}"
      nil
    rescue Curator::Exceptions::RemoteServiceError => e
      Rails.logger.error "Error Retrieving Json for Authority at #{request_uri}"
      Rails.logger.error "Reason: #{e.message}"
      nil
    end

    protected

    def call_fetch_auth_data!
      response = with_connection do |conn|
        conn.get(request_uri.to_s)
      end

      json_response = normalize_response!(response.to_s)

      raise Curator::Exceptions::RemoteServiceError.new('Failed to retrieve data from bpldc_auth_api!',
                                                        json_response, response.status) unless response.status.success?

      json_response
    end
  end
end
