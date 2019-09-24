class CreateCommonwealthCuratorMappingDescNameRoleMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mapping_desc_name_role_mappings do |t|
      t.belongs_to :descriptive, index: { using: :btree }, foreign_key: { to_table: :curator_metastreams_descriptives, on_delete: :cascade }, null: false
      t.belongs_to :name, index: { using: :btree }, foreign_key: { to_table: :curator_controlled_terms_nomenclatures, on_delete: :cascade }, null: false
      t.belongs_to :role, index: { using: :btree }, foreign_key: { to_table: :curator_controlled_terms_nomenclatures, on_delete: :cascade }, null: false
      t.index [:descriptive_id, :name_id, :role_id], unique: true, name: 'unique_idx_on_meta_desc_name_role_on_desc_name_role'
    end
  end
end
