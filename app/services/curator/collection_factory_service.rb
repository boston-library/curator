# frozen_string_literal: true

module Curator
  class CollectionFactoryService < Services::Base
    include Services::FactoryService

    def call
      institution_ark_id = @json_attrs.fetch('institution').fetch('ark_id')
      begin
        Curator.collection_class.transaction do
          institution = Curator.institution_class.find_by(ark_id: institution_ark_id)
          raise 'Institution not found!' unless institution

          collection = Curator.collection_class.find_or_initialize_by(ark_id: @ark_id)
          collection.name = @json_attrs.fetch(:name)
          collection.abstract = @json_attrs.fetch(:abstract)
          collection.institution = institution
          collection.created_at = @created if @created
          collection.updated_at = @updated if @updated
          collection.save!

          build_workflow(collection) do |workflow|
            [:ingest_origin].each do |attr|
              workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr, "#{ENV['HOME']}"))
            end
            [:processing_state, :publishing_state].each do |attr|
              workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr)) if @workflow_json_attrs.fetch(attr, nil).present?
            end
          end

          build_administrative(collection) do |administrative|
            [:description_standard, :flagged, :destination_site, :harvestable].each do |attr|
              administrative.send("#{attr}=", @admin_json_attrs.fetch(attr)) if @admin_json_attrs.fetch(attr, nil).present?
            end
          end
          return collection
        end
      rescue => e
        puts e.to_s
      end
    end
  end
end
