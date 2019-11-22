# frozen_string_literal: true

require_relative 'resource/builder'
module Curator
  module Serializers
    class Resource
       extend ActiveSupport::PerThreadRegistry

       thread_cattr_accessor :_xml_views, instance_writer: false
       thread_cattr_accessor :_json_views, instance_writer: false

       self._xml_views = Concurrent::Hash.new
       self._json_views = Concurrent::Hash.new

       def self.json
       end

       def self.xml
       end

    end
  end
end
