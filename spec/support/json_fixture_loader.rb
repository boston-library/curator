# frozen_string_literal: true

module Fixtures
  module JsonLoader
    def load_json_fixture(json_file_name = '', json_root = '')
      json_fixture = File.join(Curator::Engine.root.join('spec', 'fixtures', 'files', json_file_name))
      JSON.parse(File.read(json_fixture)).fetch(json_root, {})
    end
  end
end

RSpec.configure do |config|
  config.include Fixtures::JsonLoader
end
