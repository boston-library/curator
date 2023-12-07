# frozen_string_literal: true

module Curator
  module RetryOnFaradayException
    extend ActiveSupport::Concern

    included do
      retry_on Faraday::ConnectionFailed, Faraday::TimeoutError, wait: 30.seconds, attempts: 3
    end
  end
end
