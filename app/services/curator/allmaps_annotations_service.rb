# frozen_string_literal: true

module Curator
  class AllmapsAnnotationsService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.allmaps_annotations_url

    self.pool_options = { headers: { 'Content-Type' => 'application/json' } }.merge(Curator.config.default_remote_service_timeout_opts)
    self.pool_timeout = Curator.config.default_remote_service_pool_opts[:pool_timeout]
    self.pool_size = Curator.config.default_remote_service_pool_opts[:pool_size]

    attr_reader :iiif_manifest_url

    def initialize(iiif_manifest_url)
      raise Curator::Exceptions::RemoteServiceError.new('Invalid manifest URL') unless iiif_manifest_url

      @iiif_manifest_url = iiif_manifest_url
    end

    def allmaps_manifest_id
      Digest::SHA1.hexdigest(iiif_manifest_url)[0..15]
    end

    def call
      begin
        call_allmaps_annotations!
      rescue HttpConnectionPool::Error => e
        Rails.logger.error "Connection pool error: #{e.inspect}"
        raise
      rescue HTTP::Error => e
        base_message = 'HTTP Error Occurred Calling Allmaps Annotations Endpoint!'
        json_reason = { 'reason' => e.message }.as_json
        Rails.logger.error base_message
        Rails.logger.error "Reason: #{e.message}"
        raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
      rescue Oj::Error => e
        base_message = 'Invalid JSON Response From Allmaps Annotations Endpoint!'
        json_reason = { 'reason' => e.message }.as_json
        Rails.logger.error base_message
        Rails.logger.error "Reason: #{e.message}"
        raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occurred calling Allmaps Annotations API'
        Rails.logger.error "Reason: #{e.message}"
        Rails.logger.error "Response code: #{e.code}"
        Rails.logger.error "Response: #{e.json_response}"
        raise
      end
      nil
    end

    protected

    def call_allmaps_annotations!
      response = with_connection do |conn|
        conn.get("/manifests/#{allmaps_manifest_id}").flush
      end
      response.status.success? ? normalize_response!(response.body.to_s) : {}
    end
  end
end
