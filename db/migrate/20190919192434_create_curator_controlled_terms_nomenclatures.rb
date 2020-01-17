# frozen_string_literal: true

class CreateCuratorControlledTermsNomenclatures < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_controlled_terms_nomenclatures do |t|
      t.belongs_to :authority, index: { using: :btree }, foreign_key: { to_table: :curator_controlled_terms_authorities, on_delete: :nullify }
      t.jsonb :term_data, default: '{}', index: { using: :gin }, null: false
      t.string :type, index: { using: :btree }, null: false
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
      t.index :term_data, using: :gin, opclass: :jsonb_path_ops, name: 'index_ctl_terms_nomenclatures_on_term_data_jsonb_path_ops', using: :gin
      t.index "(term_data ->> 'id_from_auth')", name: 'index_ctl_terms_nom_id_from_auth_jsonb_field'
      t.index "((term_data ->> 'basic')::boolean)", where: "type = 'Curator::ControlledTerms::Genre'", name: 'index_ctl_terms_basic_genre_jsonb_field'
    end
  end
end
