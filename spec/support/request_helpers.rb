# frozen_string_literal: true

module Requests
  module JsonHelpers
    def json_response
      Oj.load(response.body, mode: :rails, omit_nil: true, object_class: ActiveSupport::HashWithIndifferentAccess)
    rescue StandardError
      {}
    end
  end
end

RSpec.configure do |config|
  config.include Requests::JsonHelpers, type: :request
  config.include Requests::JsonHelpers, type: :controller
end
