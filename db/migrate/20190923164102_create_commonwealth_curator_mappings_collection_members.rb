class CreateCommonwealthCuratorMappingsCollectionMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mappings_collection_members do |t|
      t.belongs_to :digital_object, index: { using: :btree, name: 'index_mapping_col_members_on_digital_object' }, foreign_key: { to_table: :curator_digital_objects, on_delete: :cascade }, null: false
      t.belongs_to :collection, index: { using: :btree, name: 'index_mapping_col_members_on_collection' }, foreign_key: { to_table: :curator_collections, on_delete: :cascade }, null: false
      t.index [:digital_object_id, :collection_id], name: 'unique_idx_mapping_col_members_on_digital_obj_and_col', unique: true, using: :btree
    end
  end
end
