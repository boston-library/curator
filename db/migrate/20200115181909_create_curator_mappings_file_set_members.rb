# frozen_string_literal: true

class CreateCuratorMappingsFileSetMembers < ActiveRecord::Migration[5.2]
  def change
    create_table 'curator.mappings_file_set_members' do |t|
      t.belongs_to :digital_object, index: { using: :btree, name: 'index_mapping_fset_members_on_digital_object' }, foreign_key: { to_table: 'curator.digital_objects' }, null: false
      t.belongs_to :file_set, index: { using: :btree, name: 'idx_fset_member_on_fset_member' }, foreign_key: { to_table: 'curator.filestreams_file_sets' }, null: false
      t.index [:digital_object_id, :file_set_id], unique: true, name: 'unique_idx_fset_mem_on_digital_obj_and_fset', using: :btree
    end
  end
end
