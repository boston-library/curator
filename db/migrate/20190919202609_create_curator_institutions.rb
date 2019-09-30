# frozen_string_literal: true
class CreateCuratorInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_institutions do |t|
      t.belongs_to :location, index: { using: :btree, name: 'index_inst_on_geo_location_nom' }, foreign_key: { to_table: :curator_controlled_terms_nomenclatures }
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.string :name, null: false
      t.string :url
      t.text :abstract, default: ''
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
    end
  end
end
