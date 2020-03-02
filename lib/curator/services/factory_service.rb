# frozen_string_literal: true

module Curator
  module Services
    module FactoryService
      extend ActiveSupport::Concern

      MAX_RETRIES = 2.freeze

      def initialize(json_data: {})
        @success = true
        @record = nil
        @json_attrs = json_data.with_indifferent_access
        @ark_id = @json_attrs.fetch('ark_id', nil)
        @created = Time.zone.parse(@json_attrs.fetch('created_at', ''))
        @updated = Time.zone.parse(@json_attrs.fetch('updated_at', ''))

        setup_metastream_attributes!
      end

      protected

      # TODO: Need to refactor these methods to handle updates as well and use the objects relationship instead of initailizing a new instance
      def build_descriptive(descriptable, &_block)
        descriptive = descriptable.build_descriptive
        yield descriptive
      end

      def build_workflow(workflowable, &_block)
        workflow = workflowable.build_workflow
        yield(workflow)
      end

      def build_administrative(administratable, &_block)
        administrative = administratable.build_administrative
        yield(administrative)
      end

      def build_exemplary(exemplary_file_set, &_block)
        exemplary = exemplary_file_set.exemplary_image_of_mappings.build
        yield(exemplary)
      end

      private

      def setup_metastream_attributes!
        metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
        @workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
        @admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
        @desc_json_attrs = metastream_json_attrs.fetch('descriptive', {}).with_indifferent_access
      end

      def find_or_create_nomenclature(nomenclature_class:, term_data: {}, authority_code: nil)
        retries = 0
        begin
          return nomenclature_class.transaction(requires_new: true) do
            break nomenclature_class.where(term_data: term_data).first_or_create! if authority_code.blank?

            authority = Curator.controlled_terms.authority_class.find_by!(code: authority_code)

            nomenclature_class.where(authority: authority, term_data: term_data).first_or_create!
          end
        rescue ActiveRecord::StaleObjectError => e
          if (retries += 1) <= MAX_RETRIES
            Rails.logger.info "Record is stale retrying in 2 seconds.."
            sleep(2)
            retry
          else
            Rails.logger.error "=================#{e.inspect}=================="
            raise ActiveRecord::RecordNotSaved, "Max retries reached! caused by: #{e.message}", e.record
          end
        end
      end

      def with_transaction(&_block)
        retries = 0
        begin
          Curator::ApplicationRecord.connection_pool.with_connection do
            Curator::ApplicationRecord.transaction do
              yield
            end
          end
        rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique, ActiveRecord::RecordNotSaved => e
          Rails.logger.error "=================#{e.inspect}=================="
          @success = false
          @record = e.record
        rescue ActiveRecord::StaleObjectError => e
          if (retries += 1) <= MAX_RETRIES
            Rails.logger.info "Record is stale retrying in 2 seconds.."
            sleep(2)
            retry
          else
            Rails.logger.error "===============MAX RETRIES REACHED!============"
            Rails.logger.error "=================#{e.inspect}=================="
            @success = false
            @record = e.record
          end
        rescue ActiveRecord::StatementInvalid => e
          Rails.logger.error "=================#{e.inspect}=================="
          @success = false
        rescue ActiveStorage::IntegrityError, ActiveStorage::Error => e
          Rails.logger.error "=================#{e.inspect}=================="
          @success = false
        rescue StandardError => e
          Rails.logger.error "=================#{e.inspect}=================="
          @success = false
        end
      end
    end
  end
end
