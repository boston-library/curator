# frozen_string_literal: true

module Curator::Middleware
  class RootApp
    RESPONSE_BODY = {
      status: 200,
      app: Curator::Engine.engine_name,
      app_version: Curator::VERSION,
      api_version: '1'
    }.freeze

    def call(env)
      dup._call(env)
    end

    protected

    def _call(env)
      if env['HTTP_ACCEPT'] != '*/*'
        case env['HTTP_ACCEPT']
        when 'application/json'
          return json_response
        when /xml/
          return xml_response
        else
          return text_response
        end
      else
        case env['PATH_INFO']
        when /json/
          return json_response
        when /xml/
          return xml_resonse
        else
          return text_response
        end
      end
    end

    private

    def json_response
      headers = { 'Content-Type' => 'application/json' }
      [RESPONSE_BODY[:status], headers, [Oj.dump(RESPONSE_BODY)]]
    end

    def xml_response
      headers = { 'Content-Type' => 'text/xml' }
      [RESPONSE_BODY[:status], headers, [RESPONSE_BODY.to_xml(root: 'curator')]]
    end

    def text_response
      headers = { 'Content-Type' => 'text/plain' }
      [RESPONSE_BODY[:status], headers, RESPONSE_BODY.to_a.map { |r| "#{r.join(' ----> ')}\n" }]
    end
  end
end
