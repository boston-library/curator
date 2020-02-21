# frozen_string_literal: true

module Curator
  module Responses
    extend ActiveSupport::Concern

    ERROR_MAP = {
        'StandardError' => 'Curator::Exceptions::ServerError',
        'ActiveRecord::RecordNotFound' => 'Curator::Exceptions::RecordNotFound',
        'ActiveRecord::RecordInvalid' => 'Curator::Exceptions::InvalidRecord',
        'ActionController::RoutingError' => 'Curator::Execptions::RouteNotFound',
        'Curator::Exceptions::UnknownFormat' => 'Curator::Exceptions::BadRequest',
        'Curator::Exceptions::UnknownSerializer' => 'Curator::Execptions::BadRequest',
        'Curator::Exceptions::UnknownResourceType' => 'Curator::Exceptions::BadRequest'
    }.freeze

    included do
      prepend_before_action :set_adapter_key

      rescue_from StandardError, with: :handle_error
    end

    protected

    def set_adapter_key
      @adapter_key = request.format.symbol
    rescue StandardError
      raise Curator::Execptions::UnknownFormat, "Unknown request mime type #{request.format}"
    end

    def multi_response(response_object, status: :ok)
      respond_to do |format|
        format.json { json_response(response_object, status) }
        format.xml { xml_response(response_object, status) }
      end
    end

    def json_response(response_object, status = :ok)
      render json: response_object, status: status
    end

    def xml_response(response_object, status = :ok)
      render xml: response_object, status: status
    end

    def handle_error(e)
      error_klass = mapped_error_klass(e)
      error_klass = Curator::Exceptions::ServerError.new if error_klass.blank?
      error = set_error(error_klass, e)

      error_response(error)
    end

    def error_response(error)
      status = error.status

      # NOTE: Errors always need to be inside an array when serializing them
      wrapped_error = if error.respond_to?(:model_errors)
                        error.model_errors
                      else
                        Array.wrap(error)
                      end

      serialized_error = Curator::ErrorSerializer.new(wrapped_error, :json).render
      json_response(serialized_error, status)
    end

    def mapped_error_klass(e)
      error_klass = e.class.name
      return e if ERROR_MAP.value?(error_klass)

      ERROR_MAP[error_klass].safe_constantize
    end

    def set_error(error_klass, e)
      return e if e.class == error_klass

      case error_klass.name
      when 'Curator::Execptions::ServerError'
        return error_klass.new(e.message)
      when 'Curator::Exceptions::InvalidRecord'
        return error_klass.new(model_errors: e&.record&.errors)
      else
        return error_klass.new(e.message, request.env['PATH_INFO'])
      end
    end
  end
end
