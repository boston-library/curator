# frozen_string_literal: true
module Curator
  class CollectionFactoryService < ServiceClass

    def initialize(file_path: "#{ENV['HOME']}/BPL-MODS-TO-RDMS/JSON/collection.json")
      @file_path = Pathname.new(file_path)
      @json_attrs = JSON.parse(@file_path.read).fetch('collection', {}).with_indifferent_access
      awesome_print @json_attrs
    end

    def call
      metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
      collection_json_attrs = metastream_json_attrs.fetch('descriptive', {}).with_indifferent_access
      workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
      admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
      institution_ark_id = @json_attrs.fetch('institution').fetch('ark_id')
      begin
        Curator.collection_class.transaction do
          @institution = Curator.institution_class.find_by(ark_id: institution_ark_id)
          @collection = Curator.collection_class.find_or_initialize_by(
            name: collection_json_attrs.fetch(:name),
            abstract: collection_json_attrs.fetch(:abstract, '')
          ) #Change to find_or_initialize_by ark_id
          @collection.institution = @institution if @institution.present?
          @collection.save!

          build_workflow do |workflow|
            [:ingest_origin, :ingest_filepath, :ingest_filename, :ingest_datastream ].each do |attr|
              workflow.send("#{attr}=", workflow_json_attrs.fetch(attr, "#{ENV['HOME']}"))
            end
            [:processing_state, :publishing_state].each do |attr|
              workflow.send("#{attr}=", workflow_json_attrs.fetch(attr)) if workflow_json_attrs.fetch(attr, nil).present?
            end
          end

          build_administrative do |administrative|
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

    def build_workflow(&block)
      workflow = Curator.metastreams.workflow_class.new(workflowable: @collection )
      yield(workflow)
      workflow.save!
    end

    def build_administrative(&block)
      administrative = Curator.metastreams.administrative_class.new(administratable: @collection )
      yield(administrative)
      administrative.save!
    end
  end
end
