# frozen_string_literal: true
module Curator
  class Filestreams::FileSetFactoryService < Services::Base
    include Services::FactoryService

    def initialize(json_attrs: {})
      @json_attrs = json_attrs.with_indifferent_access
      awesome_print @json_attrs
    end

    def call
      ark_id = @json_attrs.fetch('ark_id')
      object_ark_id = @json_attrs.dig('fileset_of', 'ark_id')
      fileset_type = @json_attrs.fetch('fileset_type', {})
      metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
      workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
      _admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
      begin
        Curator.filestreams.send("#{fileset_type}_class").transaction do
          fileset = Curator::Filestreams::const_get(fileset_type.capitalize).new(ark_id: ark_id)
          fileset.file_name_base = @json_attrs.fetch('filename_base')
          fileset.position = @json_attrs.fetch('position') || 0
          fileset.pagination = @json_attrs.fetch('pagination', {})

          object = Curator.digital_object_class.find_by(ark_id: object_ark_id)
          fileset.file_set_of = object
          fileset.save!

          # set exemplary relationships
          exemplary_ids = @json_attrs.fetch('exemplary_image_of', [])
          exemplary_ids.each do |exemplary|
            ex_ark_id = exemplary['ark_id']
            ex_obj = Curator.digital_object_class.find_by(ark_id: ex_ark_id) ||
                     Curator.collection_class.find_by(ark_id: ex_ark_id)
            raise "Bad exemplary id! #{ex_ark_id} is either not in the repo or is not a DigitalObject or Collection" unless ex_obj
            build_exemplary(ex_obj) do |exemplary|
              exemplary.file_set = fileset
            end
          end

          build_workflow(fileset) do |workflow|
            workflow.send("#{:ingest_origin}=", workflow_json_attrs.fetch(:ingest_origin, "#{ENV['HOME']}"))
            processing_state = workflow_json_attrs.fetch(:processing_state, nil)
            workflow.send("#{:processing_state}=", processing_state) if processing_state
          end

          # TODO: set access_edit_group permissions
          # build_administrative(fileset) do |administrative|
            # access_edit_group = admin_json_attrs.fetch(:access_edit_group, nil)
            # administrative.send("#{:access_edit_group}=", access_edit_group) if access_edit_group
          # end
        end
      rescue => e
        puts "#{e.to_s}"
      end
    end


  end
end
