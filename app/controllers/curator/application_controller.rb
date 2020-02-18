# frozen_string_literal: true

module Curator
  class ApplicationController < ActionController::API
    include ResourceClass
    include Responses
  end
end
