# frozen_string_literal: true

module Curator
  class ControlledTerms::CannonicalLabelService < Services::Base
    # TODO: Build microservice api to use QA and Geomesh
    def initialize(url:, json_path:)
      @url = Addressable::URI.parse(url)
      @json_path = json_path
    end

    def call
      conn = set_connection
      @url.path = "#{@url.path}#{@json_path}"
      @url = @url.to_s
      begin
        response = conn.get(@url)
        json_response = JSON.parse(response.body)
        return block_given? ? yield(json_response) : json_response
      rescue Faraday::Error => e
        Rails.logger.error "Error Retreiving Json For Authority at #{@url}"
        Rails.logger.error "Reason #{e.message}"
        nil
      rescue JSON::ParserError => e
        Rails.logger.error "Error Parsing Json For Authority at #{@url}"
        Rails.logger.error "Reason #{e.message}"
        nil
      end
      nil
    end

    protected

    def set_connection
      Faraday.new do |f|
        f.use Faraday::Response::Logger, Rails.logger
        # f.use :http_cache, store: Rails.cache #make this configurable
        f.response :follow_redirects
        f.adapter :net_http_persistent, pool_size: ENV.fetch('RAILS_MAX_THREADS') { 5 } do |http|
          http.idle_timeout = 100
          http.retry_change_requests = true
        end
      end
    end
  end
end
