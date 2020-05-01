# frozen_string_literal: true

module Curator
  module Services
    module UpdaterService
      extend ActiveSupport::Concern

      included do
        include Services::TransactionHandler
        include Services::FactoryService::NomenclatureHelpers
      end

      def initialize(record, json_data: {})
        @record = record
        @success = true
        @result = nil
        # NOTE: Had to add #to_h for when :json_data is received through the controller as ActionController::Parameters
        @json_attrs = json_data.to_h.with_indifferent_access
        @ark_id = @json_attrs.fetch('ark_id', nil)
      end

      private

      def simple_attributes_update(attributes_list = [])
        raise RuntimeError, 'no attributes given!' if attributes_list.blank?

        attributes_list.each do |attr|
          next if !should_update_attr?(attr)

          yield(attr)
        end
      end

      def should_update_attr?(attr_key)
        return false if @json_attrs.fetch(attr_key, nil).blank?

        @record.public_send(attr_key) != @json_attrs.fetch(attr_key)
      end
    end
  end
end
