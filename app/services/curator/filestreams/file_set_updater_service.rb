# frozen_string_literal: true

module Curator
  class Filestreams::FileSetUpdaterService < Services::Base
    SIMPLE_ATTRIBUTES_LIST = %i().freeze

    include Services::UpdaterService

    def call
      exemplary_file_set_ark_id = @json_attrs.dig('exemplary_file_set', 'ark_id')
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end
        @record.save!
      end

      return @success, @result
    end
  end
end
