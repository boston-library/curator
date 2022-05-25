# frozen_string_literal: true

module Curator
  class Filestreams::DerivativesService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.avi_processor_api_url
    self.default_path_prefix = '/api'
    self.default_headers = { accept: 'application/json', content_type: 'application/json' }
    self.timeout_options = Curator.config.default_remote_service_timeout_opts.merge({ connect: 120, read: 1800 })

    attr_reader :avi_file_class, :avi_payload

    # Payload should be formatted as such (use deriavtive_source helper method to get the blob)
    # {
    #   file_stream: {
    #     ark_id: ark_id,
    #     if file set type is (Image|Document|Audio|Video|Text)
    #       original_ingest_filepath: derivative_source.metatdata['ingest_filepath']
    #     elsif file set type is Ereader
    #       ebook_access_epub_data: {
    #         id: derivative_source.key
    #         storage: "#{derivative_source.service_name}_store", # Should be 'derivatives_store'
    #         metadata: {
    #              filename: derivative_source.filename.to_s,
    #              md5: derivative_source.checksum,
    #              size: derivative_source.byte_size,
    #              mime_type: derivative_source.content_type
    #         }
    #     elsif file set type is Metadata
    #        oai_thumbnail_url: # List thumbnail url(s) here
    #   }
    # }

    def initialize(avi_file_class, avi_payload: {})
      @avi_file_class = avi_file_class
      @avi_payload = avi_payload
    end

    def call
      begin
        avi_json = self.class.with_client do |client|
          call_derivatives_api(client)
        end

        return avi_json
      rescue HTTP::Error => e
        base_message = 'HTTP Error Occurred Calling Derivatives API'
        json_reason = { 'reason' => e.message }.as_json
        Rails.logger.error base_message
        Rails.logger.error "Reason: #{e.message}"
        raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
      rescue Oj::Error => e
        base_message = 'Invalid JSON Response From AVI Processor'
        json_reason = { 'reason' => e.message }.as_json
        Rails.logger.error base_message
        Rails.logger.error "Reason: #{e.message}"
        raise Curator::Exceptions::RemoteServiceError.new(base_message, json_reason, 500)
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occurred Generating Derivatives'
        Rails.logger.error "Reason: #{e.message}"
        Rails.logger.error "Response code: #{e.code}"
        Rails.logger.error "Response: #{e.json_response}"
        raise
      end
      nil
    end

    protected

    def call_derivatives_api(client)
      resp = client.headers(self.class.default_headers).
               post("#{self.class.default_path_prefix}/#{avi_file_class}", json: avi_payload).flush

      json_response = normalize_response!(resp.body.to_s)

      raise Curator::Exceptions::RemoteServiceError.new('Failed to trigger derivatives in avi_processor-api!', json_response, resp.status) if !resp.status.success?

      json_response
    end
  end
end
