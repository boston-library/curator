# frozen_string_literal: true

module Curator
  class InstitutionUpdaterService < Services::Base
    SIMPLE_ATTRIBUTES_LIST = %i(abstract url).freeze

    include Services::UpdaterService
    include ControlledTerms::Locateable
    include Filestreams::Attacher

    def initialize(record, json_data: {})
      super(record, json_data: json_data)

      @purge_blobs_on_fail = true
    end

    def call
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      host_collections_attributes = @json_attrs.fetch('host_collections_attributes', [])
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end
        @record.host_collections_attributes = host_collections_attributes if host_collections_attributes.present?

        location = location_object(location_json_attrs)
        @record.location = location unless @record.location_id == location.id

        attach_files!(@record)
        @record.save!
      end
      return @success, @result
    end
  end
end
