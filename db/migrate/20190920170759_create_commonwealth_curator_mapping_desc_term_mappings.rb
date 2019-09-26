# frozen_string_literal: true
class CreateCommonwealthCuratorMappingDescTermMappings < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mapping_desc_term_mappings do |t|
      t.belongs_to :descriptive, index: { using: :btree }, foreign_key: { to_table: :curator_metastreams_descriptives, on_delete: :cascade }, null: false
      t.belongs_to :mappable, polymorphic: true, index: { using: :btree, name: 'index_meta_desc_map_on_mappable_poly' }, null: false
      t.index [:mappable_id, :mappable_type, :descriptive_id], unique: true, name: 'unique_idx_desc_map_on_mappable_poly_and_descriptive'
    end
  end
end
