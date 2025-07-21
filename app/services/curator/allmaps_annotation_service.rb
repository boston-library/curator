# frozen_string_literal: true

module Curator
  class AllmapsAnnotationService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.allmaps_annotations_url
    self.default_path_prefix = 'manifests'
    self.default_headers = { content_type: 'application/json' }
    self.timeout_options = Curator.config.default_remote_service_timeout_opts

    attr_reader :request_uri

    def initialize(iiif_manifest_url)
      raise Curator::Exceptions::RemoteServiceError.new('Invalid manifest URL') unless iiif_manifest_url

      @request_uri = Addressable::URI.parse("#{self.class.base_url}/#{self.class.default_path_prefix}/#{allmaps_manifest_id(iiif_manifest_url)}")
    end

    def allmaps_manifest_id(iiif_manifest_url)
      Digest::SHA1.hexdigest(iiif_manifest_url)[0..15]
    end

    def call
      begin
        allmaps_annotation_response = self.class.with_client do |client|
          call_allmaps_annotation(client)
        end

        return allmaps_annotation_response
      rescue HTTP::Error => e
        base_message = 'HTTP Error Occurred Calling Allmaps Annotation Endpoint!'
        json_reason = { 'reason' => e.message }.as_json
        Rails.logger.error base_message
        Rails.logger.error "Reason: #{e.message}"
        raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
      rescue Oj::Error => e
        base_message = 'Invalid JSON Response From Allmaps Annotation Endpoint!'
        json_reason = { 'reason' => e.message }.as_json
        Rails.logger.error base_message
        Rails.logger.error "Reason: #{e.message}"
        raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occurred calling Allmaps Annotation API'
        Rails.logger.error "Reason: #{e.message}"
        Rails.logger.error "Response code: #{e.code}"
        Rails.logger.error "Response: #{e.json_response}"
        raise
      end
      nil
    end

    protected

    def call_allmaps_annotation(client)
      resp = client.headers(self.class.default_headers).get(request_uri.to_s).flush
      resp.status.success? ? normalize_response!(resp.body.to_s) : {}
    end
  end
end
