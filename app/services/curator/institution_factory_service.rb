# frozen_string_literal: true

module Curator
  class InstitutionFactoryService < Services::Base
    include Services::FactoryService

    def call
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      with_transaction do
        @record = Curator.institution_class.with_metastreams.new(ark_id: @ark_id)
        @record.name = @json_attrs.fetch(:name)
        @record.abstract = @json_attrs.fetch(:abstract, '')
        @record.url = @json_attrs.fetch(:url, nil)
        @record.location = location(location_json_attrs) if location_json_attrs.present?
        @record.created_at = @created if @created
        @record.updated_at = @updated if @updated

        build_workflow(@record) do |workflow|
          workflow.ingest_origin = @workflow_json_attrs.fetch(:ingest_origin, ENV['HOME'].to_s)
          publishing_state = @workflow_json_attrs.fetch(:publishing_state, nil)
          processing_state = @workflow_json_attrs.fetch(:processing_state, nil)
          workflow.publishing_state = publishing_state if publishing_state
          workflow.processing_state = processing_state if processing_state
        end

        build_administrative(@record) do |administrative|
          destination_site = @admin_json_attrs.fetch(:destination_site, nil)
          administrative.destination_site = destination_site if destination_site
        end
        @record.save!
      end
      return @success, @result
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
