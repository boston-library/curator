# frozen_string_literal: true

module Curator
  class CollectionUpdaterService < Services::Base
    SIMPLE_ATTRIBUTES_LIST = %i(abstract).freeze

    include Services::UpdaterService

    def call
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |attr|
          @record.public_send("#{attr_key}=", @json_attrs.fetch(attr))
        end
        @record.save!
      end

      return @success, @result
    end
  end
end
