# frozen_string_literal: true

module Curator
  module Services
    module RemoteService

      extend ActiveSupport::Concern
      #TODO Should be able to to set net_http_persistent and default connection options according to faraday docs
      #TODO Make threadsafe class level instance variable for storing base uri for service
      private
      def client
        return @client if defined?(@client)
        @client = Faraday.new(url: @base_url.to_s) do |f|
          f.use Faraday::Response::Logger, Rails.logger
          f.use :http_cache, store: Rails.cache #make this configurable
          f.adapter :net_http_persistent, pool_size: ENV.fetch('RAILS_MAX_THREADS', 5) do |http|
            http.idle_timeout = 120
            http.read_timeout = 120
            http.open_timeout = 60
            http.retry_change_requests = true
            end
          end
        end
      end
    end
  end
