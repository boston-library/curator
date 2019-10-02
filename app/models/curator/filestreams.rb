# frozen_string_literal: true
module Curator
  module Filestreams
    extend ActiveSupport::Autoload
    extend Curator::NamespaceAccessor
    def self.table_name_prefix
      'curator_filestreams_'
    end

    def self.file_set_types
      %w(Image Ereader Document Text Metadata Audio Video).freeze
    end

    autoload_under 'file_sets' do
      self.file_set_types.each do |fset_type|
        puts "autoloading #{fset_type}"
        autoload fset_type.to_sym
      end
    end


    namespace_klass_accessor :audio
    namespace_klass_accessor :document
    namespace_klass_accessor :ereader
    namespace_klass_accessor :image
    namespace_klass_accessor :text
    namespace_klass_accessor :video
  end
end
