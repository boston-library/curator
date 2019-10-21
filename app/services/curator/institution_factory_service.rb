# frozen_string_literal: true
module Curator
  class InstitutionFactoryService < Services::Base
    include Services::FactoryService

    def initialize(json_attrs: {})
      @json_attrs = json_attrs.with_indifferent_access
      awesome_print @json_attrs
    end

    def call
      institution_json_attrs = @json_attrs
      metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
      workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
      admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      ark_id = @json_attrs.fetch('ark_id')
      begin
        Curator.institution_class.transaction do
          institution = Curator.institution_class.find_or_initialize_by(ark_id: ark_id)
          institution.name = institution_json_attrs.fetch(:name)
          institution.abstract = institution_json_attrs.fetch(:abstract)
          institution.url = institution_json_attrs.fetch(:url)
          institution.location = location(location_json_attrs) unless location_json_attrs.blank?
          institution.save!

          build_workflow(institution) do |workflow|
            workflow.send("#{:ingest_origin}=", workflow_json_attrs.fetch(:ingest_origin, "#{ENV['HOME']}"))
            publishing_state = workflow_json_attrs.fetch(:publishing_state, nil)
            processing_state = workflow_json_attrs.fetch(:processing_state, nil)
            workflow.send("#{:publishing_state}=", publishing_state) if publishing_state
            workflow.send("#{:processing_state}=", processing_state) if processing_state #
          end

          build_administrative(institution) do |administrative|
            destination_site = admin_json_attrs.fetch(:destination_site, nil)
            administrative.send("#{:destination_site}=", destination_site) if destination_site
          end
        end
      rescue => e
        puts "#{e.to_s}"
      end
    end

    protected

    def location(json_attrs={})
      find_or_create_nomenclature(
        nomenclature_class: Curator.controlled_terms.geographic_class,
        term_data: json_attrs.except(:authority_code),
        authority_code: json_attrs.fetch(:authority_code, nil)
      )
    end
  end
end
