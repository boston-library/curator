# frozen_string_literal: true
class CreateCommonwealthCuratorMappingsExemplaryImages < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mappings_exemplary_images do |t|
      t.belongs_to :file_set, index: { using: :btree }, foreign_key: { to_table: :curator_filestreams_file_sets, on_delete: :cascade }, null: false
      t.belongs_to :exemplary, polymorphic: true, index: { using: :btree, name: 'idx_map_exemp_img_on_exemp' }, null: false
      t.index [:file_set_id, :exemplary_id, :exemplary_type], name: 'unique_idx_mappings_exemp_img_on_exemp_type_and_id_and_fset', unique: true, using: :btree
    end
  end
end
