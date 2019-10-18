# frozen_string_literal: true
module Curator
  class CollectionFactoryService < Services::Base
    include Services::FactoryService
    def initialize(json_attrs: {})
      @json_attrs = json_attrs.with_indifferent_access
      awesome_print @json_attrs
    end

    def call
      metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
      workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
      admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
      institution_ark_id = @json_attrs.fetch('institution').fetch('ark_id')
      begin
        Curator.collection_class.transaction do
          @institution = Curator.institution_class.find_by(ark_id: institution_ark_id)
          @collection = Curator.collection_class.find_or_initialize_by(
            name: @json_attrs.fetch(:name),
            abstract: @json_attrs.fetch(:abstract, '')
          ) #Change to find_or_initialize_by ark_id
          @collection.institution = @institution if @institution.present?
          @collection.save!

          build_workflow(@collection) do |workflow|
            [:ingest_origin].each do |attr|
              workflow.send("#{attr}=", workflow_json_attrs.fetch(attr, "#{ENV['HOME']}"))
            end
            [:processing_state, :publishing_state].each do |attr|
              workflow.send("#{attr}=", workflow_json_attrs.fetch(attr)) if workflow_json_attrs.fetch(attr, nil).present?
            end
          end

          build_administrative(@collection) do |administrative|
            [:description_standard, :flagged, :destination_site, :harvestable].each do |attr|
              administrative.send("#{attr}=", admin_json_attrs.fetch(attr)) if admin_json_attrs.fetch(attr, nil).present?
            end
          end
        end
      rescue => e
        puts "#{e.to_s}"
      end
    end
  end
end
