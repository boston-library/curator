# frozen_string_literal: true
class CreateCommonwealthCuratorControlledTermsAuthorities < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_controlled_terms_authorities do |t|
      t.string :name, null: false
      t.string :code, index: { unique: true, using: :btree }
      t.string :base_url
      t.timestamps null: false
      t.integer :lock_version
      t.boolean :active, default: true
      t.index [:code, :base_url], unique: true, where: 'base_url is not null', using: :btree
      t.index :active, where: 'active = true', using: :btree
    end
  end
end
