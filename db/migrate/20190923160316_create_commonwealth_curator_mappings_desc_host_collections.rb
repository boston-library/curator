class CreateCommonwealthCuratorMappingsDescHostCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mappings_desc_host_collections do |t|
      t.belongs_to :host_collection, index: { using: :btree }, foreign_key: { to_table: :curator_mappings_host_collections }, null: false
      t.belongs_to :descriptive, index: { using: :btree }, foreign_key: { to_table: :curator_metastreams_descriptives }, null: false
      t.index [:descriptive_id, :host_collection_id], unique: true, using: :btree
    end
  end
end
