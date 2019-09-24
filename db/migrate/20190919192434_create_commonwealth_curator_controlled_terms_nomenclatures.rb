# frozen_string_literal: true
class CreateCommonwealthCuratorControlledTermsNomenclatures < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_controlled_terms_nomenclatures do |t|
      t.belongs_to :authority, index: { using: :btree }, foreign_key: { to_table: :curator_controlled_terms_authorities, on_delete: :cascade }
      t.jsonb :term_data, default: '{}', index: { using: :gin, opclass: :jsonb_path_ops }, null: false
      t.string :type, index: { using: :btree }, null: false
      t.integer :lock_version
      t.timestamps null: false
      t.boolean :archived, index: { using: :btree }, default: false, null: false
      t.index '(term_data->"id_from_auth")', using: :gin, opclass: :jsonb_path_ops
      t.index :archived, where: 'archived = false', using: :btree
    end
  end
end
