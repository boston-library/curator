# frozen_string_literal: true

module Curator
  class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    include Responses

    def method_not_allowed
      raise Curator::Exceptions::NotAllowed
    end
  end
end
