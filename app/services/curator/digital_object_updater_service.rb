# frozen_string_literal: true

module Curator
  class DigitalObjectUpdaterService < Services::Base
    include Services::UpdaterService
    include CreateOrReplaceExemplary

    def call
      exemplary_file_set_ark_id = @json_attrs.dig('exemplary_file_set', 'ark_id')
      collection_members_attrs =  @json_attrs.fetch('collection_members', []).map(&:with_indifferent_access).delete_if { |cm| [:id, :ark_id].all? { |key| cm[key].blank? } }
      with_transaction do
        create_or_replace_exemplary!(exemplary_file_set_ark_id)
        create_or_update_collection_members!(collection_members_attrs)
        @record.save!
      end

      return @success, @result
    end

    protected

    def create_or_update_collection_members!(collection_members_attrs = [])
      return if collection_members_attrs.blank?

      members_to_add = collection_members_attrs.select(&should_add_collection_member?).pluck(:ark_id)
      members_to_remove = collection_members_attrs.select(&should_remove_collection_member?).pluck(:id)

      return if members_to_add.blank? && members_to_remove.blank?

      add_collection_members(members_to_add)
      remove_collection_members(members_to_remove)
    end

    def remove_collection_members(members_to_remove = [])
      return if members_to_remove.blank?

      # NOTE: Dont remove the collection member if it belongs to the #admin_set collection for the #admin_set

      @record.collection_members.can_remove.where(id: members_to_remove.uniq).destroy_all if @record.collection_members.can_remove.find(members_to_remove.uniq)
    end

    def add_collection_members(members_to_add = [])
      return if members_to_add.blank?

      return unless can_add_members_scope.find_by!(ark_id: members_to_add.uniq)

      can_add_members_scope.where(ark_id: members_to_add.uniq).find_each do |collection|
        @record.collection_members.build(collection: collection)
      end
    end

    private

    def can_add_members_scope
      # NOTE: the #admin_set should always be mapped
      Curator.collection_class
                              .select(:id, :ark_id, :institution_id)
                              .where(institution_id: @record.institution.id)
                              .where
                              .not(id: record_collection_member_ids.uniq)
    end

    def record_collection_member_ids
      [@record.admin_set_id] + @record.collection_members.pluck(:collection_id)
    end

    def should_add_collection_member?
      proc { |cm| cm[:_destroy].blank? && cm[:ark_id].present? }
    end

    def should_remove_collection_member?
      proc { |cm| cm[:_destroy].present? && cm[:id].present? }
    end
  end
end
