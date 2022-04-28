# frozen_string_literal: true

module Curator
  class ErrorSerializer < Curator::Serializers::AbstractSerializer
    build_schema_as_json do
      root_key :error, :errors

      attributes :status, :title, :detail, :source
    end

    build_schema_as_xml do
      node :errors, multi_valued: true do
        target_value_as :title
        attribute :status

        element :detail

        element :source do
          attribute :pointer
        end
      end
    end

    build_schema_as_mods do
      node :errors, multi_valued: true do
        target_value_as :title
        attribute :status

        element :detail

        element :source do
          attribute :pointer
        end
      end
    end
  end
end
