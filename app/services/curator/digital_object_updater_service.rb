# frozen_string_literal: true

module Curator
  class DigitalObjectUpdaterService < Services::Base
    include Services::UpdaterService
    include CreateOrReplaceExemplary

    def call
      exemplary_file_set_ark_id = @json_attrs.dig('exemplary_file_set', 'ark_id')
      collection_members_attrs =  @json_attrs.fetch('collection_members', []).map(&:with_indifferent_access).delete_if { |cm| [:id, :ark_id].all? {|key| cm[key].blank? } }
      with_transaction do
        create_or_replace_exemplary!(exemplary_file_set_ark_id)
        @record.save!
      end

      return @success, @result
    end

    protected

    def create_or_update_collection_members!(collection_members_attrs = [])
      return if collection_members_attrs.blank?

      members_to_remove = collection_members_attrs.dup.select(&should_remove_collection_member?)
      members_to_add = collection_members_attrs.dup.pluck(:ark_id).compact

      return if members_to_add.blank? && members_to_remove.blank?

      # NOTE: Using #find with an array of ids raises an exception if ANY value in the array does not exist
      # We definetly want to leverage that insde of factory/updater services to raise errors.

      members_to_remove.pluck(:id).each do |member_id|
        @record.collection_members.find(member_id).mark_for_destruction
      end

      return if members_to_add.blank?

      institution_collections = @record.institution.collections.select(:ark_id, :id)

      members_to_add.pluck(:ark_id).each do |member_ark_id|
        col = institution_collections.find_by!(ark_id: member_ark_id)

        @record.collection_members.build(collection_id: col.id) unless @record.collection_members.exists?(collection_id: col.id)
      end
    end

    private

    def should_remove_collection_member?
      proc { |cm| cm[:id].present? && cm[:_deleted].present? }
    end
  end
end
