# frozen_string_literal: true

module Curator
  module Services
    module FactoryService
      extend ActiveSupport::Concern

      included do
        include Services::TransactionHandler
        include NomenclatureHelpers
      end

      def initialize(json_data: {})
        @record = nil
        @success = true
        @result = nil
        # NOTE: Had to add #to_h for when :json_data is received through the controller as ActionController::Parameters
        @json_attrs = json_data.to_h.with_indifferent_access
        @ark_id = @json_attrs.fetch('ark_id', nil)
        @created = Time.zone.parse(@json_attrs.fetch('created_at', ''))
        @updated = Time.zone.parse(@json_attrs.fetch('updated_at', ''))

        setup_metastream_attributes!
      end

      protected

      def build_descriptive(descriptable, &_block)
        descriptive = descriptable.descriptive.presence || descriptable.build_descriptive
        yield descriptive
      end

      def build_workflow(workflowable, &_block)
        workflow = workflowable.workflow.presence || workflowable.build_workflow
        yield(workflow)
      end

      def build_administrative(administratable, &_block)
        administrative = administratable.administrative.presence || administratable.build_administrative
        yield(administrative)
      end

      def build_exemplary(exemplary_file_set, &_block)
        exemplary = exemplary_file_set.exemplary_image_of_mappings.build
        yield(exemplary)
      end

      def setup_metastream_attributes!
        metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
        @workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
        @admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
        @desc_json_attrs = metastream_json_attrs.fetch('descriptive', {}).with_indifferent_access
      end

      # NOTE: This will check if there is an object present based on the field used for the local_original_identifier in ark_params
      def check_for_existing_ark!
        return if defined?(@ark_id) && @ark_id.present?

        @ark_id = local_id_finder_scope&.ark_id
      end

      private

      def local_id_finder_scope
        Rails.logger.warn 'Override me in included classes!'
        nil
      end

      module NomenclatureHelpers
        READONLY_NOMENCLATURE_CLASSES = [
          'Curator::ControlledTerms::Role',
          'Curator::ControlledTerms::ResourceType',
          'Curator::ControlledTerms::Language',
          'Curator::ControlledTerms::License',
          'Curator::ControlledTerms::RightsStatement'
        ].freeze

        private

        # raise error if term is from pre-seeded class and not found (new values are not allowed)
        def find_or_create_nomenclature(nomenclature_class:, term_data: {}, authority_code: nil)
          return if term_data.blank?

          term_data = term_data.dup.symbolize_keys

          authority = Curator.controlled_terms.authority_class.find_by!(code: authority_code) if authority_code.present?

          case nomenclature_class.name
          when 'Curator::ControlledTerms::Genre'
            return find_nomenclature!(nomenclature_class, term_data, authority) if term_data[:basic].present?

            return find_nomenclature(nomenclature_class, term_data, authority) || create_nomenclature!(nomenclature_class, term_data, authority)
          when *READONLY_NOMENCLATURE_CLASSES
            return find_nomenclature!(nomenclature_class, term_data, authority)
          else
            return find_nomenclature(nomenclature_class, term_data, authority) || create_nomenclature!(nomenclature_class, term_data, authority)
          end
        rescue ActiveRecord::RecordNotFound
          nomenclature_type = nomenclature_class.name.demodulize
          raise ActiveRecord::RecordNotSaved, "Invalid data submitted for #{nomenclature_type}: #{term_data} is not allowed."
        rescue ActiveRecordError => e
          raise ActiveRecord::RecordNotSaved, "Could not save record due to an error creating nomenclature! Reason #{e.message}"
        end

        # Tries to find nomenclature but silently fails.
        def find_nomenclature(nomenclature_class, term_data = {}, authority = nil)
          find_nomenclature!(nomenclature_class, term_data, authority)
        rescue ActiveRecord::RecordNotFound
          nil
        end

        def find_nomenclature!(nomenclature_class, term_data = {}, authority = nil)
          return nomenclature_class.jsonb_contains(**term_data).first! if authority.blank?

          nomenclature_class.where(authority: authority).jsonb_contains(**term_data).first!
        end

        def create_nomenclature!(nomenclature_class, term_data = {}, authority = nil)
          return nomenclature_class.create!(term_data: term_data) if authority.blank?

          nomenclature_class.create!(authority: authority, term_data: term_data)
        end
      end
    end
  end
end
