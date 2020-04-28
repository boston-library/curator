# frozen_string_literal: true

module Curator
  class Metastreams::AdministrativeUpdaterService < Services::Base
    include Services::UpdaterService

    UPDATEABLE_ATTRIBUTES = %i(destination_site flagged description_standard harvestable).freeze

    def call
      access_edit_group_attrs = @json_attrs.fetch('access_edit_group', [])
      with_transaction do
        UPDATEABLE_ATTRIBUTES.each do |attr_key|
          next if !should_update_attr(attr_key)

          @record.public_send("#{attr_key}=", @json_attrs.fetch(attr_key))
        end

        access_edit_group_attrs.each do |access_edit_group_attr|
          Rails.logger.debug "TODO: Add access_edit_group #{access_edit_group} to this object"
        end

        @record.save!
      end

      return @success, @result
    end
  end
end
