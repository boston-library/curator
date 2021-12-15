# frozen_string_literal: true

module Curator
  class Filestreams::DerivativesService < Services::Base
    include Curator::Services::RemoteService

    self.base_url = Curator.config.avi_processor_api_url
    self.default_path_prefix = '/api'
    self.default_headers = { accept: 'application/json', content_type: 'application/json' }

    attr_reader :avi_file_class, :avi_payload

    # Payload should be formatted as such (use deriavtive_source helper method to get the blob)
    # {
    #   file_stream: {
    #   "[image|audio|document|video]_stream": {
    #     ark_id: ark_id,
    #     if file set type is (image|document|audio|video|text)
    #       original_ingest_filepath: derivative_source.metatdata['ingest_filepath']
    #     elsif file set type is ereader
    #       ebook_access_epub_data: {
    #         id: derivative_source.key
    #         storage:
    #       }
    #    }
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
        Rails.logger.error 'HTTP Error Occurred Calling Derivatives API'
        Rails.logger.error "Reason: #{e.message}"
      rescue Oj::Error => e
        Rails.logger.error 'Invalid JSON Response From AVI Processor'
        Rails.logger.error "Reason: #{e.message}"
      rescue Curator::Exceptions::RemoteServiceError => e
        Rails.logger.error 'Error Occurred Generating Derivatives'
        Rails.logger.error "Reason: #{e.message}"
        Rails.logger.error "Response code: #{e.code}"
        Rails.logger.error "Response: #{e.json_response}"
      end
      nil
    end

    protected

    def call_derivatives_api(client)
      resp = client.headers(self.class.default_headers).
               post("#{self.class.default_path_prefix}/#{avi_file_class}", json: avi_payload).flush

      json_response = Oj.load(resp.body.to_s)

      raise Curator::Exceptions::RemoteServiceError.new('Failed to trigger derivatives in avi_processor-api!', json_response, resp.status) if !resp.status.success?

      json_response
    end
  end
end
