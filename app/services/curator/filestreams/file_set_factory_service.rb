# frozen_string_literal: true
module Curator
  class Filestreams::FileSetFactoryService < Services::Base
    include Services::FactoryService

    def initialize(json_attrs: {})
      @json_attrs = json_attrs.with_indifferent_access
      awesome_print @json_attrs
    end

    def call
      object_ark_id = @json_attrs.dig('fileset_of', 'ark_id')
      fileset_type = @json_attrs.fetch('fileset_type', {})
      metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
      workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
      _admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
      begin
        Curator.filestreams.send("#{fileset_type}_class").transaction do
          fileset = Curator::Filestreams::const_get(fileset_type.capitalize).new
          object = Curator.digital_object_class.find_by(ark_id: object_ark_id)
          fileset.file_set_of = object
          exemplary_ids = @json_attrs.fetch('exemplary_image_of', [])
          exemplary_ids.each do |exemplary|
            ex_ark_id = exemplary['ark_id']
            ex_obj = Curator.digital_object_class.find_by(ark_id: ex_ark_id) ||
                     Curator.collection_class.find_by(ark_id: ex_ark_id)
            if ex_obj.class == Curator.digital_object_class
              fileset.exemplary_image_objects << ex_obj
            elsif ex_obj.class == Curator.digital_object_class
              fileset.exemplary_image_collections << ex_obj
            else
              raise "Bad exemplary image ID! #{ex_ark_id} is either not in the repo or is not a DigitalObject or Collection"
            end
          end
          fileset.save!

          build_workflow(institution) do |workflow|
            workflow.send("#{:ingest_origin}=", workflow_json_attrs.fetch(:ingest_origin, "#{ENV['HOME']}"))
            processing_state = workflow_json_attrs.fetch(:processing_state, nil)
            workflow.send("#{:processing_state}=", processing_state) if processing_state
          end

          # TODO: set access_edit_group permissions
          # build_administrative(institution) do |administrative|
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
