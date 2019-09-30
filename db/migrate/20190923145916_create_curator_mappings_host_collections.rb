# frozen_string_literal: true
class CreateCuratorMappingsHostCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mappings_host_collections do |t|
      t.string :name, null: false
      t.belongs_to :institution, index: { using: :btree }, foreign_key: { to_table: :curator_institutions, on_delete: :cascade }, null: false
      t.index [:name, :institution_id], name: 'unique_idx_map_host_col_col_and_and_name', unique: true, using: :btree
    end
  end
end
