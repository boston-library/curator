# frozen_string_literal: true

module Curator
  module Exceptions
    class RecordNotFound < SerializableError
      def initialize(raised_ex = nil)
        pointer = if raised_ex.present?
                    path = raised_ex&.model&.safe_constantize&._to_partial_path
                    "#{path}/#{raised_ex&.id}"
                  else
                    '/request/url/:id'
                  end
        super(
          title: 'Record Not Found',
          status: :not_found,
          detail: message || 'Object not found',
          source: { pointer: pointer }
        )
      end
    end


    class ModelError < SerializableError
      def initalize(errors: {})
        @errors = errors
        @status = :bad_request
        @title = "Bad Request"
      end

      def serializable_hash
        errors.reduce([]) do |r, (att, msg)|
          r << {
            status: status,
            title: title,
            detail: msg,
            source: { pointer: "/data/attributes/#{att}" }
          }
        end
      end

      private
      attr_reader :errors
    end

    class InvalidEntity < ModelError
      def initalize(errors: {})
        super(errors: errors)
        @status = :unprocessable_entity
        @title = "Unprocessable Entity"
      end
    end
  end
end
