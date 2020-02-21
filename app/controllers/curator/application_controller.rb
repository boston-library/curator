# frozen_string_literal: true

module Curator
  class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    include Responses
  end
end
