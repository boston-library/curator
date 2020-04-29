# frozen_string_literal: true

module Curator
  class Metastreams::WorkflowUpdaterService < Services::Base
    include Services::UpdaterService

    SIMPLE_ATTRIBUTES_LIST = %i(publishing_state).freeze

    def call
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{attr_key}=", @json_attrs.fetch(attr_key))
        end
        @record.save!
      end

      return @success, @result
    end
  end
end
