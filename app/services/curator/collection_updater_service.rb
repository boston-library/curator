# frozen_string_literal: true

module Curator
  class CollectionUpdaterService < Services::Base
    SIMPLE_ATTRIBUTES_LIST = %i(abstract).freeze
    include Services::UpdaterService
    include Mappings::CreateOrReplaceExemplary

    def call
      exemplary_file_set_ark_id = @json_attrs.dig('exemplary_file_set', 'ark_id')
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST, SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end

        create_or_replace_exemplary!(exemplary_file_set_ark_id)
        @record.save!
      end

      [@success, @result]
    end
  end
end
