# frozen_string_literal: true

class CreateCuratorMappingsDescHostCollections < ActiveRecord::Migration[5.2]
  def change
    create_table 'curator.mappings_desc_host_collections' do |t|
      t.belongs_to :host_collection, index: { using: :btree, name: 'index_desc_mapping_host_col_on_host_col' }, foreign_key: { to_table: 'curator.mappings_host_collections' }, null: false
      t.belongs_to :descriptive, index: { using: :btree, name: 'index_desc_mapping_host_col_on_desc' }, foreign_key: { to_table: 'curator.metastreams_descriptives' }, null: false
      t.index [:descriptive_id, :host_collection_id], name: 'unique_idx_desc_mappping_of_col_on_desc_and_host_col', unique: true, using: :btree
    end
  end
end
