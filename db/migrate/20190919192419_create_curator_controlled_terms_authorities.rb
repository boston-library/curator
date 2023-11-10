# frozen_string_literal: true

class CreateCuratorControlledTermsAuthorities < ActiveRecord::Migration[5.2]
  def change
    enable_extension 'pg_trgm' if !extension_enabled?('pg_trgm')
    enable_extension 'pgcrypto' if !extension_enabled?('pgcrypto')
    enable_extension 'btree_gin' if !extension_enabled?('btree_gin')

    # NOTE: we should create the schema in production as part of our ops procedure. So we can add the AUTHORIZATION options to the production user we are using. See https://www.postgresql.org/docs/12/ddl-schemas.html#DDL-SCHEMAS-PRIV

    execute 'CREATE SCHEMA IF NOT EXISTS curator;'

    create_table 'curator.controlled_terms_authorities' do |t|
      t.string :name, null: false
      t.string :code
      t.string :base_url
      t.integer :lock_version
      t.timestamps null: false
      t.index :code, unique: true, where: "code is not null and code != ''", name: 'unique_idx_ctrl_term_auth_on_code', using: :btree
      t.index [:base_url, :code], unique: true, where: "base_url is not null and base_url != '' and code is not null and code != ''", name: 'unique_idx_ctrl_term_auth_on_base_url', using: :btree
    end
  end
end
