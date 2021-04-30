# frozen_string_literal: true

class CreateCuratorCollections < ActiveRecord::Migration[5.2]
  def change
    create_table 'curator.collections' do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.belongs_to :institution, index: { using: :btree }, foreign_key: { to_table: 'curator.institutions' }, null: false
      t.string :name, null: false
      t.text :abstract, default: ''
      t.integer :lock_version
      t.timestamps null: false
    end
  end
end
