class CreateCommonwealthCuratorCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_collections do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.belongs_to :institution, index: { using: :btree, unique: true }, foreign_key: { to_table: :curator_institutions }, null: false
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :deleted_at, index: { using: :btree }
    end
  end
end
