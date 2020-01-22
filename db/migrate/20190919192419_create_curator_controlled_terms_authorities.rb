# frozen_string_literal: true

class CreateCuratorControlledTermsAuthorities < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'pg_trgm'
    enable_extension 'pgcrypto'
    enable_extension 'btree_gin'

    create_table :curator_controlled_terms_authorities do |t|
      t.string :name, null: false
      t.string :code
      t.string :base_url
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
      t.index :code, unique: true, where: "code is not null and code != ''", name: 'unique_idx_ctrl_term_auth_on_code', using: :btree
      t.index [:base_url, :code], unique: true, where: "base_url is not null and base_url != '' and code is not null and code != ''", name: 'unique_idx_ctrl_term_auth_on_base_url', using: :btree
    end
  end
end
