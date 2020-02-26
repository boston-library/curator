# frozen_string_literal: true

module Curator
  module Exceptions
    extend ActiveSupport::Autoload

    # Base Exception for everything curataor related
    class CuratorError < StandardError; end

    # Base exception for any error expected to be serialized in controller
    class SerializableError < CuratorError

      attr_reader :title, :detail, :status, :source

      delegate :to_s, to: :to_h

      def initialize(title: 'Something went wrong', detail: 'We encountered unexpected error', status: 500, source: {})
        @title, @detail = title, detail
        @status = Rack::Utils.status_code(status)
        @source = source.deep_stringify_keys
      end

      # These methods are for if we ever need to render to a text format
      def as_json(options = {})
        root = options.fetch(:root, false)

        hash = to_h.as_json

        return {'error' => hash } if root

        hash
      end

      def to_h
        {
          status: status,
          title: title,
          detail: detail,
          source: source
        }
      end
    end

    # Base exception wrapper for generating an array of exceptions related to a model's errors
    class ModelError < SerializableError
      attr_reader :model_errors
      def initalize(model_errors: {})
        @model_errors = format_model_errors(model_errors)
        @status = :bad_request
        @title = 'Bad Request'
      end

      protected

      def format_model_errors(errors = {})
        errors.reduce([]) do |r, (att, msg)|
          r << self.class.superclass.new(
            title: title,
            status: status,
            detail: msg,
            source: { pointer: "/data/attributes/#{att}" }
          )
        end
      end
    end

    eager_autoload do
      # General Raiseable exceptions
      autoload :UnknownFormat, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :UnknownSerializer, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :UnknownResourceType, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :UndeletableResource, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      # SerializableError Subclasses
      autoload :BadRequest, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :Unauthorized, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :RouteNotFound,  File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :RecordNotFound, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :ServerError, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :MethodNotAllowed, File.expand_path('./exceptions/controller_errors.rb', __dir__)
      autoload :NotAcceptable, File.expand_path('./exceptions/controller_errors.rb', __dir__) 
      # Serializable ModelError Subclasses
      autoload :InvalidRecord, File.expand_path('./exceptions/model_errors.rb', __dir__)
    end
  end
end
