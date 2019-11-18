# frozen_string_literal: true

module Fixtures
  module JsonLoader
    def load_json_fixture(json_root = '')
      json_fixture = file_fixture("#{json_root}.json").read
      JSON.parse(json_fixture).fetch(json_root, {}).with_indifferent_access
    end
  end
end

RSpec.configure do |config|
  config.include Fixtures::JsonLoader
end
