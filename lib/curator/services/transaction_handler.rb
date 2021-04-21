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
          purge_unattached_files! #NOTE Will call purge_later on unattached files if success == false
          handle_result!
        end
      end
    end
  end
end
