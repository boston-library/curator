# frozen_string_literal: true

module Curator
  class CollectionFactoryService < Services::Base
    include Services::FactoryService

    def call
      with_transaction do
        institution_ark_id = @json_attrs.dig('institution', 'ark_id')
        institution = Curator.institution_class.find_by!(ark_id: institution_ark_id)

        @record = Curator.collection_class.with_metastreams.new(ark_id: @ark_id)
        @record.name = @json_attrs.fetch(:name)
        @record.abstract = @json_attrs.fetch(:abstract, '')
        @record.institution = institution
        @record.created_at = @created if @created
        @record.updated_at = @updated if @updated

        build_workflow(@record) do |workflow|
          [:ingest_origin].each do |attr|
            workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr, ENV['HOME'].to_s))
          end
          [:processing_state, :publishing_state].each do |attr|
            workflow.send("#{attr}=", @workflow_json_attrs.fetch(attr)) if @workflow_json_attrs.fetch(attr, nil).present?
          end
        end

        build_administrative(@record) do |administrative|
          [:description_standard, :flagged, :destination_site, :harvestable].each do |attr|
            administrative.send("#{attr}=", @admin_json_attrs.fetch(attr)) if @admin_json_attrs.fetch(attr, nil).present?
          end
        end

        @record.save!
      end
    ensure
      handle_result!
      return @success, @result
    end
  end
end
