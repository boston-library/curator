# frozen_string_literal: true

module Curator
  class Metastreams::WorkflowUpdaterService < Services::Base
    include Services::UpdaterService

    UPDATEABLE_ATTRIBUTES = %i(publishing_state).freeze

    def call
      with_transaction do
        UPDATEABLE_ATTRIBUTES.each do |attr_key|
          next if !should_update_attr(attr_key)

          @record.public_send("#{attr_key}=", @json_attrs.fetch(attr_key))
        end

        @record.save!
      end
      
      return @success, @result
    end
  end
end
