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

      module NomenclatureHelpers
        private

        def find_or_create_nomenclature(nomenclature_class:, term_data: {}, authority_code: nil)
          nomenclature = nil
          retries = 0
          term_data = term_data.dup.symbolize_keys
          begin
            nomenclature_class.transaction(requires_new: true) do
              nomenclature =
                if authority_code.blank?
                  find_nomenclature(nomenclature_class, term_data) || create_nomenclature!(nomenclature_class, term_data)
                else
                  authority = Curator.controlled_terms.authority_class.find_by!(code: authority_code)

                  find_nomenclature(nomenclature_class, term_data, authority) || create_nomenclature!(nomenclature_class, term_data, authority)
                end
            end
            return nomenclature
          rescue ActiveRecord::StaleObjectError => e
            raise ActiveRecord::RecordNotSaved, "Max retries reached! caused by: #{e.message}", e.record unless (retries += 1) <= TransactionHandler::MAX_RETRIES

            Rails.logger.info 'Record is stale retrying in 2 seconds..'
            sleep(2)
            retry
          rescue *TransactionHandler::RESULT_ERRORS => e
            Rails.logger.error '==============================================='
            Rails.logger.error "=================#{e.inspect}=================="
            Rails.logger.error '==============================================='
            Rails.logger.error e.backtrace.join("\n")
            Rails.logger.error '==============================================='
            raise e
          end
        end

        def find_nomenclature(nomenclature_class, term_data = {}, authority = nil)
          return nomenclature_class.jsonb_contains(**term_data).first if authority.blank?

          nomenclature_class.where(authority: authority).jsonb_contains(**term_data).first
        end

        # raise error if term is from pre-seeded class and not found (new values are not allowed)
        def create_nomenclature!(nomenclature_class, term_data = {}, authority = nil)
          nomenclature = nomenclature_class.new
          raise_error = case nomenclature
                        when Curator.controlled_terms.resource_type_class,
                             Curator.controlled_terms.role_class,
                             Curator.controlled_terms.language_class,
                             Curator.controlled_terms.license_class,
                             Curator.controlled_terms.rights_statement_class
                          true
                        when Curator.controlled_terms.genre_class
                          true if term_data[:basic] == true
                        else
                          false
                        end
          if raise_error
            nomenclature_type = nomenclature_class.name.demodulize
            nomenclature.errors.add(nomenclature_type.downcase.to_sym,
                                    "Invalid data submitted for #{nomenclature_type}: #{term_data} is not allowed.")
            raise ActiveRecord::RecordInvalid, nomenclature
          end

          return nomenclature_class.create!(term_data: term_data) if authority.blank?

          nomenclature_class.create!(authority: authority, term_data: term_data)
        end
      end
    end
  end
end
