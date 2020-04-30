# frozen_string_literal: true

module Curator
  class DigitalObjectUpdaterService < Services::Base
    include Services::UpdaterService
    include CreateOrReplaceExemplary

    def call
      exemplary_file_set_ark_id = @json_attrs.dig('exemplary_file_set', 'ark_id')
      collection_members_attrs =  @json_attrs.fetch('collection_members', [])
      with_transaction do
        create_or_replace_exemplary!(exemplary_file_set_ark_id)
        @record.save!
      end

      return @success, @result
    end

    protected

    def create_or_update_collection_members(collection_members_attrs = [])
      return if collection_members_attrs.blank?
    end
  end
end
