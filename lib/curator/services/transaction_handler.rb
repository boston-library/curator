# frozen_string_literal: true

module Curator
  module Services
    module TransactionHandler
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
                        ActiveStorage::Error,
                        ActiveStorage::IntegrityError,
                        ActiveStorage::FileNotFoundError,
                        SystemCallError,
                        ArgumentError,
                        NameError,
                        NoMethodError,
                        StandardError
                      ].freeze

      private

      def handle_result!
        @success = false if @record.blank?

        return if defined?(@result) && @result.present?

        return if @record.blank?

        @result = @record.class.respond_to?(:for_serialization) ? @record.class.for_serialization.find(@record.id) : @record
      end

      def purge_unattached_files!
        return if @success == true

        ActiveStorage::Blob.unattached.find_each(&:purge_later)
      end

      def with_transaction(&_block)
        retries = 0
        begin
          Rails.application.executor.wrap do
            Curator::ApplicationRecord.transaction do
              begin
                yield
              rescue ActiveRecord::StaleObjectError => e
                if (retries += 1) <= MAX_RETRIES
                  Rails.logger.info 'Record is stale retrying in 3 seconds...'
                  sleep(3)
                  retry
                else
                  Rails.logger.error '===============MAX RETRIES REACHED!============'
                  Rails.logger.error "=================#{e.inspect}=================="

                  raise ActiveRecord::RecordNotSaved.new("Max retries reached! caused by: #{e.message}", e.record)
                end
              end
            end
          end
        rescue *RESULT_ERRORS => e
          Rails.logger.error "=================#{e.inspect}=================="
          @success = false
          @result = e
        ensure
          handle_result!
          purge_unattached_files! # NOTE This Will call purge_later on unattached files if success == false
        end
      end
    end
  end
end
