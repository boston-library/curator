# frozen_string_literal: true

module Curator
  class ApplicationController < ActionController::API
    include ActionController::MimeResponds
    prepend_before_action :set_serializer_adapter_key

    ERROR_MAP = {
      'StandardError' => 'Curator::Exceptions::ServerError',
      'ActiveRecord::RecordNotFound' => 'Curator::Exceptions::RecordNotFound',
      'ActiveRecord::RecordInvalid' => 'Curator::Exceptions::InvalidRecord',
      'ActionController::RoutingError' => 'Curator::Exceptions::RouteNotFound',
      'Curator::Exceptions::UnknownFormat' => 'Curator::Exceptions::BadRequest',
      'Curator::Exceptions::UnknownSerializer' => 'Curator::Exceptions::BadRequest',
      'Curator::Exceptions::UnknownResourceType' => 'Curator::Exceptions::BadRequest',
      'Curator::Exceptions::UndeletableResource' => 'Curator::Exceptions::NotAllowed'
    }.freeze

    def method_not_allowed
      raise Curator::Exceptions::UndeletableResource, 'Resource cannot be deleted'
    end

    def not_found
      raise ActionController::RoutingError, 'URL not found'
    end

    rescue_from StandardError, with: :handle_error

    protected

    def set_serializer_adapter_key
      Rails.logger.debug "== request format is #{request.format.inspect} =="

      raise StandardError, "Invalid format key #{request.format&.symbol}" unless Curator::Serializers.registered_adapter_keys.include?(request.format&.symbol)

      @serializer_adapter_key = request.format.symbol
    rescue StandardError => e
      Rails.logger.error "===========#{e.inspect}================"
      raise Curator::Exceptions::UnknownFormat, 'Unknown serializer adapter'
    end

    def multi_response(rendered_object, status: :ok)
      respond_to do |format|
        format.json { json_response(rendered_object, status) }
        format.xml { xml_response(rendered_object, status) }
      end
    end

    def json_response(rendered_object, status = :ok)
      render json: rendered_object, status: status
    end

    def xml_response(rendered_object, status = :ok)
      render xml: rendered_object, status: status
    end

    def handle_error(e)
      error_klass = mapped_error_klass(e)
      error_klass = Curator::Exceptions::ServerError if error_klass.blank?
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

      ERROR_MAP[error_klass]&.safe_constantize
    end

    def set_error(error_klass, e)
      return e if e.kind_of?(error_klass)

      case error_klass.to_s
      when 'Curator::Execptions::ServerError'
        return error_klass.new(e.message)
      when 'Curator::Exceptions::InvalidRecord'
        return error_klass.new(model_errors: e&.record&.errors || {})
      else
        return error_klass.new(e.message, request.env['PATH_INFO'])
      end
    end
  end
end
