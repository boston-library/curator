# frozen_string_literal: true

module Curator
  module Services
    module FactoryService
      extend ActiveSupport::Concern

      MAX_RETRIES = 2
      # These are errors that will be passed to the @result variable. That way these can be raised on failure up the chain
      RESULT_ERRORS = [
                        ActiveRecord::RecordNotFound,
                        ActiveRecord::StatementInvalid,
                        ActiveRecord::RecordInvalid,
                        ActiveRecord::RecordNotUnique,
                        ActiveRecord::RecordNotSaved,
                        ActiveRecord::ActiveRecordError,
                        SystemCallError,
                        ArgumentError,
                        NameError,
                        NoMethodError,
                        StandardError
                      ].freeze

      def initialize(json_data: {})
        @record = nil
        @success = true
        @result = nil
        # NOTE: Had to add #to_h for when :json_data is recieved through the controller as ActionController::Parameters
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

      private

      def handle_result!
        @success = false if @record.blank?

        return if defined?(@result) && @result.present?

        return if @record.blank?

        @result = @record.class.respond_to?(:for_serialization) ? @record.class.for_serialization.find(@record.id) : @record
      end

      def setup_metastream_attributes!
        metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
        @workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
        @admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
        @desc_json_attrs = metastream_json_attrs.fetch('descriptive', {}).with_indifferent_access
      end

      def find_or_create_nomenclature(nomenclature_class:, term_data: {}, authority_code: nil)
        retries = 0
        term_data = term_data.dup.symbolize_keys
        begin
          return nomenclature_class.transaction(requires_new: true) do
            break find_nomenclature(nomenclature_class, term_data) || create_nomenclature!(nomenclature_class, term_data) if authority_code.blank?

            authority = Curator.controlled_terms.authority_class.find_by!(code: authority_code)

            find_nomenclature(nomenclature_class, term_data, authority) || create_nomenclature!(nomenclature_class, term_data, authority)
          end
        rescue ActiveRecord::StaleObjectError => e
          raise ActiveRecord::RecordNotSaved, "Max retries reached! caused by: #{e.message}", e.record unless (retries += 1) <= MAX_RETRIES

          Rails.logger.info 'Record is stale retrying in 2 seconds..'
          sleep(2)
          retry
        rescue *RESULT_ERRORS => e
          Rails.logger.error "=================#{e.inspect}=================="
          raise e
        end
      end

      # find existing ControlledTerms objects
      # raise error if term is from pre-seeded class and not found (new values are not allowed)
      def find_nomenclature(nomenclature_class, term_data = {}, authority = nil)
        nomenclature = if authority.blank?
                         nomenclature_class.jsonb_contains(**term_data).first
                       else
                         nomenclature_class.where(authority: authority).jsonb_contains(**term_data).first
                       end
        raise_error = case nomenclature_class.new
                      when Curator.controlled_terms.resource_type_class,
                           Curator.controlled_terms.role_class,
                           Curator.controlled_terms.language_class,
                           Curator.controlled_terms.license_class
                        true unless nomenclature
                      when Curator.controlled_terms.genre_class
                        true if nomenclature.blank? && term_data[:basic] == true
                      else
                        false
                      end
        raise ActiveRecord::RecordInvalid if raise_error

        nomenclature
      end

      def create_nomenclature!(nomenclature_class, term_data = {}, authority = nil)
        return nomenclature_class.create!(term_data: term_data) if authority.blank?

        nomenclature_class.create!(authority: authority, term_data: term_data)
      end

      def with_transaction(&_block)
        retries = 0
        begin
          Curator::ApplicationRecord.connection_pool.with_connection do
            Curator::ApplicationRecord.transaction do
              yield
            end
          end
        rescue ActiveRecord::StaleObjectError => e
          if (retries += 1) <= MAX_RETRIES
            Rails.logger.info '====Record is stale retrying in 2 seconds...==='
            sleep(2)
            retry
          else
            Rails.logger.error '===============MAX RETRIES REACHED!============'
            Rails.logger.error "=================#{e.inspect}=================="
            @success = false
            @result = ActiveRecord::RecordNotSaved, "Max retries reached! caused by: #{e.message}", e.record
          end
        rescue *RESULT_ERRORS => e
          Rails.logger.error "=================#{e.inspect}=================="
          @success = false
          @result = e
        ensure
          handle_result!
        end
      end
    end
  end
end
