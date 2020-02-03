# frozen_string_literal: true

module Curator
  module Decorators
    extend ActiveSupport::Autoload
    class BaseDecorator < SimpleDelegator; end
    eager_autoload do
      autoload :MetastreamDecorator
      autoload :DescSubjectDecorator
    end
  end
end
