# frozen_string_literal: true

module Curator
  class DigitalObjectUpdaterService < Services::Base
    include Services::UpdaterService
    include Mappings::CreateOrReplaceExemplary

    def call
      exemplary_file_set_ark_id = @json_attrs.dig('exemplary_file_set', 'ark_id')
      collection_members_attrs =  @json_attrs.fetch('is_member_of_collection', []).map(&:with_indifferent_access).delete_if { |cm| cm[:ark_id].blank? }
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

      should_remove_collection_member = ->(cm) { cm[:_destroy].present? && cm[:_destroy] == '1' }
      should_add_collection_member = ->(cm) { !should_remove_collection_member.call(cm) }

      members_to_add = collection_members_attrs.select(&should_add_collection_member).pluck(:ark_id)
      members_to_remove = collection_members_attrs.select(&should_remove_collection_member).pluck(:ark_id)

      return if members_to_add.blank? && members_to_remove.blank?

      add_collection_members(members_to_add)
      remove_collection_members(members_to_remove)
    end

    def remove_collection_members(members_to_remove = [])
      return if members_to_remove.blank?

      # NOTE: Dont remove the collection member if it belongs to the #admin_set collection for the #admin_set
      return unless @record.is_member_of_collection.find_by!(ark_id: members_to_remove.uniq)

      @record.is_member_of_collection.where(ark_id: members_to_remove.uniq).find_each do |collection|
        @record.collection_members.can_remove.find_by!(collection: collection).destroy!
      end
    rescue ActiveRecord::RecordNotFound => e
      @record.errors.add(:is_member_of_collection, "REMOVING: #{e.message} with ark ids IN #{members_to_remove.uniq.join(', ')}")
      raise ActiveRecord::RecordInvalid, @record
    end

    def add_collection_members(members_to_add = [])
      return if members_to_add.blank?

      return unless member_collections_scope.find_by!(ark_id: members_to_add.uniq)

      member_collections_scope.where(ark_id: members_to_add.uniq).find_each do |collection|
        @record.collection_members.build(collection: collection)
      end
    rescue ActiveRecord::RecordNotFound => e
      @record.errors.add(:is_member_of_collection, "ADDING: #{e.message} with ark ids IN #{members_to_add.uniq.join(', ')}")
      raise ActiveRecord::RecordInvalid, @record
    end

    private

    def member_collections_scope
      # NOTE: the #admin_set should always be mapped
      Curator.collection_class
                              .select(:id, :ark_id, :institution_id)
                              .where(institution_id: @record.institution.id)
                              .where
                              .not(id: record_collection_member_ids)
    end

    def record_collection_member_ids
      ([@record.admin_set_id] + @record.collection_members.pluck(:collection_id)).uniq
    end
  end
end
