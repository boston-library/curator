# frozen_string_literal: true

class CreateCuratorControlledTermsAuthorities < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'pg_trgm'
    enable_extension 'pgcrypto'

    create_table :curator_controlled_terms_authorities do |t|
      t.string :name, null: false
      t.string :code, index: { unique: true, using: :btree }
      t.string :base_url
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
      t.index [:code, :base_url], unique: true, where: 'base_url is not null', using: :btree
    end
  end
end
