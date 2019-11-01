# frozen_string_literal: true

module Curator
  module Services
    module FactoryService
      extend ActiveSupport::Concern

      def initialize(json_data: {})
        @json_attrs = json_data.with_indifferent_access
        @ark_id = @json_attrs.fetch('ark_id')
        metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
        @workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
        @admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
        @desc_json_attrs = metastream_json_attrs.fetch('descriptive', {}).with_indifferent_access
        @created = Time.zone.parse(@json_attrs.fetch('created_at'))
        @updated = Time.zone.parse(@json_attrs.fetch('updated_at'))
        awesome_print @json_attrs
      end

      protected

      def build_descriptive(descriptable, &_block)
        descriptive = Metastreams::Descriptive.new(descriptable: descriptable)
        yield descriptive
        descriptive.save!
      end

      def build_workflow(workflowable, &_block)
        workflow = Curator.metastreams.workflow_class.new(workflowable: workflowable)
        yield(workflow)
        workflow.save!
      end

      def build_administrative(administratable, &_block)
        administrative = Curator.metastreams.administrative_class.new(administratable: administratable)
        yield(administrative)
        administrative.save!
      end

      def build_exemplary(exemplary_object, &_block)
        exemplary = Curator.mappings.exemplary_image_class.new(exemplary_object: exemplary_object)
        yield(exemplary)
        exemplary.save!
      end

      private

      def find_or_create_nomenclature(nomenclature_class:, term_data: {}, authority_code: nil)
        begin
          return nomenclature_class.where(term_data: term_data).first_or_create! if authority_code.blank?

          authority = Curator.controlled_terms.authority_class.find_by(code: authority_code)
          raise "No authority found with the code #{authority_code}!" if authority.blank?

          return nomenclature_class.where(authority: authority, term_data: term_data).first_or_create!
        rescue => e
          puts e.message
        end
        nil
      end
    end
  end
end
