# frozen_string_literal: true

module Fixtures
  module JsonLoader
    def load_json_fixture(json_filename = '', json_root = nil)
      json_fixture = file_fixture("#{json_filename}.json").read
      JSON.parse(json_fixture).fetch((json_root || json_filename), {}).with_indifferent_access
    end
  end
end

RSpec.configure do |config|
  config.include Fixtures::JsonLoader
end
