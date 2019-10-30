# frozen_string_literal: true

module Curator
  class MinterService < Services::Base
    def initialize()
      @namespace = "commonwealth"
    end

    def call
      "#{@namespace}:#{SecureRandom.hex(5)}"
    end
  end
end
