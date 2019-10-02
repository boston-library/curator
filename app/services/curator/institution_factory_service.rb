# frozen_string_literal: true
module Curator
  class InstitutionFactoryService < ServiceClass
    include DigitalRepository::FactoryService

    def initialize(file_path: "#{ENV['HOME']}/BPL-MODS-TO-RDMS/JSON/institution.json")
      @file_path = Pathname.new(file_path)
      @json_attrs = JSON.parse(@file_path.read).fetch('institution', {}).fetch('metastreams').with_indifferent_access
      awesome_print @json_attrs
    end

    def call
      institution_json_attrs = @json_attrs.fetch('descriptive', {}).with_indifferent_access
      workflow_json_attrs = @json_attrs.fetch('workflow', {}).with_indifferent_access
      admin_json_attrs = @json_attrs.fetch('administrative', {}).with_indifferent_access
      location_json_attrs = institution_json_attrs.fetch('subject', {}).fetch('geo', {}).with_indifferent_access
      begin
        Curator.institution_class.transaction do
          institution = Curator.institution_class.find_or_initialize_by(
            name: institution_json_attrs.fetch(:name),
            abstract: institution_json_attrs.fetch(:abstract)
          ) #Change to find_or_initialize_by ark_id
          institution.location = location(location_json_attrs) unless location_json_attrs.blank?
          institution.save!

          build_workflow(institution) do |workflow|
            [:ingest_origin, :ingest_filepath, :ingest_filename, :ingest_datastream ].each do |attr|
              workflow.send("#{attr}=", workflow_json_attrs.fetch(attr, "#{ENV['HOME']}"))
            end
            [:processing_state, :publishing_state].each do |attr|
              workflow.send("#{attr}=", workflow_json_attrs.fetch(attr)) if workflow_json_attrs.fetch(attr, nil).present?
            end
          end

          build_administrative(institution) do |administrative|
            [:description_standard, :flagged, :destination_site, :harvestable].each do |attr|
              administrative.send("#{attr}=", admin_json_attrs.fetch(attr)) if admin_json_attrs.fetch(attr, nil).present?
            end
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
