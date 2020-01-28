# frozen_string_literal: true

module Curator
  class InstitutionFactoryService < Services::Base
    include Services::FactoryService

    def call
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      begin
        Curator.institution_class.transaction do
          institution = Curator.institution_class.find_or_initialize_by(ark_id: @ark_id)
          institution.name = @json_attrs.fetch(:name)
          institution.abstract = @json_attrs.fetch(:abstract, nil)
          institution.url = @json_attrs.fetch(:url, nil)
          institution.location = location(location_json_attrs) if location_json_attrs.present?
          institution.created_at = @created if @created
          institution.updated_at = @updated if @updated
          institution.save!

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
          return institution
        end
      rescue => e
        puts e.to_s
      end
    end

    protected

    def location(json_attrs = {})
      find_or_create_nomenclature(
        nomenclature_class: Curator.controlled_terms.geographic_class,
        term_data: json_attrs.except(:authority_code),
        authority_code: json_attrs.fetch(:authority_code, nil)
      )
    end
  end
end
