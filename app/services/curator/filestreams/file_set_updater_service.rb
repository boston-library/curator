# frozen_string_literal: true

module Curator
  class Filestreams::FileSetUpdaterService < Services::Base
    SIMPLE_ATTRIBUTES_LIST = %i(position).freeze
    PAGINATION_ATTRIBUTES_LIST = %i(page_label page_type page_size).freeze

    include Services::UpdaterService

    def call
      exemplary_image_of_attrs = @json_attr.fetch(:exemplary_image_of, [])
      pagination_attributes = @json_attr.fetch(:pagination, {})
      with_transaction do
        simple_attributes_update(SIMPLE_ATTRIBUTES_LIST) do |simple_attr|
          @record.public_send("#{simple_attr}=", @json_attrs.fetch(simple_attr))
        end
        update_pagination!(pagination_attrs)

        @record.save!
      end

      return @success, @result
    end

    protected

    def update_exemplary_image_of!(exemplary_image_of_attrs = [])
      return if exemplary_image_of_attrs.blank?

    end

    def update_pagination!(pagination_attrs = {})
      return if pagination_attr.empty?

      PAGINATION_ATTRIBUTES_LIST.each do |pagination_attr|
        @record.public_send("#{pagination_attr}=", pagination_attrs[pagination_attr]) if pagination_attrs[pagination_attr].present?
      end
    end

    private

    def add_exemplary_image_of!(exemplary_image_of_ark_ids = [])
      return if exemplary_image_of_ark_ids.blank?

    end

    def remove_exemplary_image_of!(exemplary_image_of_ark_ids = [])
      return if exemplary_image_of_ark_ids.blank?
      
    end
  end
end
