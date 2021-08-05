# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativeUpdaterService < Services::Base
    include Services::UpdaterService

    SIMPLE_ATTRIBUTES_LIST = %i(destination_site flagged description_standard harvestable oai_header_id).freeze

    def call
      access_edit_group_attrs = @json_attrs.fetch('access_edit_group', [])
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr)) if @json_attrs[simple_attr].presence
        end

        access_edit_group_attrs.each do |access_edit_group_attr|
          Rails.logger.debug "TODO: Add access_edit_group #{access_edit_group_attr} to this object"
        end

        @record.save!
      end

      return @success, @result
    end
  end
end
