# frozen_string_literal: true
class CreateCommonwealthCuratorControlledTermsNomenclatures < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_controlled_terms_nomenclatures do |t|
      t.belongs_to :authority, index: { using: :btree }, foreign_key: {to_table: :curator_controlled_terms_authorities}
      t.jsonb :term_data, default: '{}', index: { using: :gin, opclass: :jsonb_path_ops }, null: false
      t.string :type, index: { using: :btree }, null: false
      t.integer :lock_version
      t.timestamps null: false
      t.boolean :active, default: true, null: false
      t.index :active, where: 'active = true', using: :btree
      t.index '(term_data->"id_from_auth")', using: :gin, opclass: :jsonb_path_ops
    end
  end
end
