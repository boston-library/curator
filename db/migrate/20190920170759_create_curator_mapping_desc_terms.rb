# frozen_string_literal: true

class CreateCuratorMappingDescTerms < ActiveRecord::Migration[5.2]
  def change
    create_table 'curator.mappings_desc_terms' do |t|
      t.belongs_to :descriptive, index: { using: :btree }, foreign_key: { to_table: 'curator.metastreams_descriptives' }, null: false
      t.belongs_to :mapped_term, index: { using: :btree, name: 'index_meta_desc_map_on_nomencaluture' }, foreign_key: { to_table: 'curator.controlled_terms_nomenclatures' }, null: false
      t.index [:mapped_term_id, :descriptive_id], unique: true, name: 'unique_idx_desc_map_on_mappable_poly_and_descriptive'
    end
  end
end
