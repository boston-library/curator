# frozen_string_literal: true

module Curator
  class MinterService < Services::Base
    include ArkService

    attr_reader :ark_create_params

    def initialize(ark_manager_params = {})
      @ark_manager_params = ark_manager_params
      @ark = nil
    end

    def call
      begin
        ark_json = self.class.client_yielder do |client|
          generate_ark(client)
        end

        return ark_json['ark']['pid'] if ark_json.dig('ark', 'pid')

        raise "Ark Create Response Contained Errors #{ark_json.inspect}" if ark_json.present?

        raise 'Empty Response came back from ark manager check logs or if in active state.'
      rescue => e
        Rails.logger.error 'Error Occured Generating Ark'
        Rails.logger.error "Reason #{e.message}"
        raise 'Error Generating Ark!'
      end
    end

    protected

    def generate_ark(client)
      Concurrent::Promises.future do
        client.headers(self.class.default_headers).
               post("#{self.class.default_endpoint_prefix}/arks", json: ark_manager_params)
      end.then do |resp|
        Oj.load(resp.body) rescue {}
      end.value!
    end
  end
end
