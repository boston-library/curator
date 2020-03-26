# frozen_string_literal: true

module Curator
  module AuthorityApiUtil
    ##
    # check if the BPLDC Authority API service is online
    def self.authority_api_ready?
      begin
        api_response = Faraday.head(ENV['AUTHORITY_API_URL'])
        api_response&.status == 200 ? true : false
      rescue => e
        puts "ERROR: BPLDC Authority API is not ready: #{e}"
        false
      end
    end
  end
end