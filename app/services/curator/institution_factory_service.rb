# frozen_string_literal: true

module Curator
  class InstitutionFactoryService < Services::Base
    include Services::FactoryService
    include Locateable

    def call
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      image_thumbnail_300_attrs = @json_attrs.fetch('image_thumbnail_300', {}).with_indifferent_access
      with_transaction do
        @record = Curator.institution_class.where(ark_id: @ark_id).first_or_create! do |institution|
          institution.name = @json_attrs.fetch(:name, nil)
          institution.abstract = @json_attrs.fetch(:abstract, '')
          institution.url = @json_attrs.fetch(:url, nil)
          institution.location = location_object(location_json_attrs) if location_json_attrs.present?
          institution.created_at = @created if @created
          institution.updated_at = @updated if @updated
          institution.image_thumbnail_300.attach(image_thumbnail_300_attrs) if image_thumbnail_300_attrs.present?

          build_workflow(institution) do |workflow|
            workflow.ingest_origin = @workflow_json_attrs.fetch(:ingest_origin, ENV['HOME'].to_s)
            publishing_state = @workflow_json_attrs.fetch(:publishing_state, nil)
            processing_state = @workflow_json_attrs.fetch(:processing_state, nil)
            workflow.publishing_state = publishing_state if publishing_state
            workflow.processing_state = processing_state if processing_state
          end

          build_administrative(institution) do |administrative|
            destination_site = @admin_json_attrs.fetch(:destination_site, nil)
            administrative.destination_site = destination_site if destination_site
          end
        end

      end
      return @success, @result
    end
  end
end
