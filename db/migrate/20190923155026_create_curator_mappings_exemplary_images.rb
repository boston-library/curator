# frozen_string_literal: true

class CreateCuratorMappingsExemplaryImages < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mappings_exemplary_images do |t|
      t.belongs_to :exemplary_object, polymorphic: true, index: { using: :btree, name: 'idx_map_exemp_img_on_exemp_obj_poly' }, null: false, unique: true
      t.belongs_to :exemplary_file_set, index: { using: :btree, name: 'idx_map_exemp_on_exemp_file_set' }, foreign_key: { to_table: :curator_filestreams_file_sets, on_delete: :cascade }, null: false
      t.index [:exemplary_file_set_id, :exemplary_object_id, :exemplary_object_type], name: 'uniq_idx_map_exemp_img_on_exemp_obj_poly_and_exemp_fse', unique: true, using: :btree
    end
  end
end
