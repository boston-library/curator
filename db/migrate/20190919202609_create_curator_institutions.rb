# frozen_string_literal: true

class CreateCuratorInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table 'curator.institutions' do |t|
      t.belongs_to :location, index: { using: :btree, name: 'index_inst_on_geo_location_nom' }, foreign_key: { to_table: 'curator.controlled_terms_nomenclatures', on_delete: :nullify }
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.string :name, null: false
      t.string :url
      t.text :abstract, default: ''
      t.integer :lock_version
      t.timestamps null: false
    end
  end
end
