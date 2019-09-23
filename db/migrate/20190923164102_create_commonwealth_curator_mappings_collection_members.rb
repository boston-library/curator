class CreateCommonwealthCuratorMappingsCollectionMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mappings_collection_members do |t|
      t.belongs_to :digital_object, index: { using: :btree }, foreign_key: { to_table: :curator_digital_objects }, null: false
      t.belongs_to :collection, index: { using: :btree }, foreign_key: { to_table: :curator_collections }, null: false
      t.index [:digital_object_id, :collection_id], unique: true, using: :btree
    end
  end
end
