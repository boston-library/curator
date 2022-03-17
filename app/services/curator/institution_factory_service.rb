# frozen_string_literal: true

module Curator
  class InstitutionFactoryService < Services::Base
    include Services::FactoryService
    include ControlledTerms::Locateable
    include Filestreams::Attacher

    def initialize(json_data: {})
      super(json_data: json_data)

      @purge_blobs_on_fail = true
    end

    def call
      location_json_attrs = @json_attrs.fetch('location', {}).with_indifferent_access
      with_transaction do
        check_for_existing_ark!
        @record = Curator.institution_class.find_or_initialize_by(ark_id: @ark_id).tap do |institution|
          institution.name = @json_attrs.fetch(:name, nil)
          institution.abstract = @json_attrs.fetch(:abstract, '')
          institution.url = @json_attrs.fetch(:url, nil)
          institution.location = location_object(location_json_attrs) if location_json_attrs.present?
          institution.created_at = @created if @created
          institution.updated_at = @updated if @updated

          build_workflow(institution) do |workflow|
            workflow.ingest_origin = @workflow_json_attrs.fetch(:ingest_origin, ENV['HOME'].to_s)
            publishing_state = @workflow_json_attrs.fetch(:publishing_state, nil)
            workflow.publishing_state = publishing_state if publishing_state
          end

          build_administrative(institution) do |administrative|
            destination_site = @admin_json_attrs.fetch(:destination_site, nil)
            administrative.destination_site = destination_site if destination_site
          end
          attach_files!(institution) if institution.valid?
          institution.save!
        end
      end
      return @success, @result
    end

    private

    def local_id_finder_scope
      name = @json_attrs.fetch(:name, nil)

      return if name.blank?

      Curator.institution_class.local_id_finder(name)&.first
    end
  end
end
