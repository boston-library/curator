# frozen_string_literal: true
class CreateCommonwealthCuratorControlledTermsAuthorities < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'pg_trgm'
    enable_extension 'pgcrypto'
    enable_extension 'isn'

    create_table :curator_controlled_terms_authorities do |t|
      t.string :name, null: false
      t.string :code, index: { unique: true, using: :btree }
      t.string :base_url
      t.timestamps null: false
      t.integer :lock_version
      t.datetime :deleted_at, index: { using: :btree, where: 'deleted_at is null' }
      t.index [:code, :base_url], unique: true, where: 'base_url is not null', using: :btree
    end
  end
end
