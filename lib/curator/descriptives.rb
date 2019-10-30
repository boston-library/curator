# frozen_string_literal: true

module Curator
  module Descriptives
    extend ActiveSupport::Autoload
    eager_autoload do
      autoload :FieldSet
    end

    autoload_under 'field_sets' do
      autoload :Cartographic
      autoload :Date
      autoload :Identifier
      autoload :Note
      autoload :Publication
      autoload :Related
      autoload :Subject
      autoload :Title
      autoload :TitleSet
    end
  end
end
