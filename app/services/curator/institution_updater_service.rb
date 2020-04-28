# frozen_string_literal: true

module Curator
  class InstitutionUpdaterService < Services::Base
    include Services::UpdaterService
    include Locateable

    UPDATEABLE_ATTRIBUTES = %i(abstract url host_collection_attributes).freeze

    def call
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      image_thumbnail_300_attrs = @json_attrs.fetch('image_thumbnail_300', {}).with_indifferent_access
      with_transaction do
        UPDATEABLE_ATTRIBUTES.each do |attr_key|
          next if !should_update_attr(attr_key)

          @record.public_send("#{attr_key}=", @json_attrs.fetch(attr_key))
        end

        location = location_object(location_json_attrs)
        @record.location = location unless @record.location_id == location.id

        if image_thumbnail_300_attrs.present?
          @record.image_thumbnail_300.purge_later if @record.image_thumbnail_300.attached?
          @record.image_thumbnail_300.attach(image_thumbnail_300_attrs)
        end

        @record.save!
      end
      return @success, @result
    end
  end
end
