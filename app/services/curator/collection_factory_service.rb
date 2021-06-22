# frozen_string_literal: true

module Curator
  class CollectionFactoryService < Services::Base
    include Services::FactoryService

    def call
      with_transaction do
        institution_ark_id = @json_attrs.dig('institution', 'ark_id')
        @record = Curator.collection_class.find_or_initialize_by(ark_id: @ark_id).tap do |collection|
          collection.name = @json_attrs.fetch(:name, nil)
          collection.abstract = @json_attrs.fetch(:abstract, '')
          collection.institution = Curator.institution_class.find_by(ark_id: institution_ark_id)
          collection.created_at = @created if @created
          collection.updated_at = @updated if @updated

          build_workflow(collection) do |workflow|
            [:ingest_origin].each do |attr|
              workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr, ENV['HOME'].to_s))
            end
            [:publishing_state].each do |attr|
              workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr)) if @workflow_json_attrs.fetch(attr, nil).present?
            end
          end

          build_administrative(collection) do |administrative|
            [:description_standard, :flagged, :destination_site, :harvestable, :hosting_status].each do |attr|
              administrative.send("#{attr}=", @admin_json_attrs.fetch(attr)) if @admin_json_attrs.fetch(attr, nil).present?
            end
          end
          collection.save!
        end
      end
      return @success, @result
    end
  end
end
