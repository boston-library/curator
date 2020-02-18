# frozen_string_literal: true

module Curator
  module Responses
    extend ActiveSupport::Concern

    ERROR_MAP = {
        ''
    }.freeze

    included do
      include ActionController::MimeResponds

      before_action :set_adapter_key

      rescue_from ActiveRecord::RecordNotFound, with: -> (e) { handle_error(e) }
    end

    protected
    def set_adapter_key
      @adapter_key = request.format&.symbol
    end

    def send_response(response_object, status: :ok)
      respond_to do |format|
        format.json { json_response(response_object, status) }
        format.xml { xml_response(response_object, status) }
      end
    end

    def handle_error(e)
    end
    private

    def json_response(response_object, status = :ok)
      render json: resource_object, status: status
    end

    def xml_response(response_object, status = :ok)
      render xml: resource_object, status: status
    end
  end
end
