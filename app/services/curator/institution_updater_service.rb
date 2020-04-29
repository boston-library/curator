# frozen_string_literal: true

module Curator
  class InstitutionUpdaterService < Services::Base
    SIMPLE_ATTRIBUTES_LIST = %i(abstract url).freeze

    include Services::UpdaterService
    include Locateable

    def call
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      image_thumbnail_300_attrs = @json_attrs.fetch('image_thumbnail_300', {}).symbolize_keys
      host_collections_attributes = @json_attrs.fetch('host_collections_attributes', [])
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end
        @record.host_collections_attributes = host_collections_attributes if host_collections_attributes.present?

        location = location_object(location_json_attrs)
        @record.location = location unless @record.location_id == location.id

        if image_thumbnail_300_attrs.present?
          # Get rid of previous thumbnail before attaching new one
          @record.image_thumbnail_300.purge if @record.image_thumbnail_300.attached?
          @record.image_thumbnail_300.attach(**image_thumbnail_300_attrs)
        end

        @record.save!
      end
      return @success, @result
    end
  end
end
