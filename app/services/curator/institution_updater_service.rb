# frozen_string_literal: true

module Curator
  class InstitutionUpdaterService < Services::Base
    SIMPLE_ATTRIBUTES_LIST = %i(abstract url).freeze
    include Services::UpdaterService
    include ControlledTerms::Locateable
    include Mappings::CreateOrReplaceExemplary

    def call
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      host_collections_attributes = @json_attrs.fetch('host_collections_attributes', [])
      exemplary_file_set_ark_id = @json_attrs.dig('exemplary_file_set', 'ark_id')

      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST, SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end
        @record.host_collections_attributes = host_collections_attributes if host_collections_attributes.present?

        location = location_object(location_json_attrs)
        @record.location = location unless @record.location_id == location&.id

        create_or_replace_exemplary!(exemplary_file_set_ark_id)
        @record.save!
      end

      [@success, @result]
    end
  end
end
