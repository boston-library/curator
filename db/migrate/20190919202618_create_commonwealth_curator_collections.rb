class CreateCommonwealthCuratorCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_collections do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.belongs_to :institution, index: { using: :btree, unique: true }, foreign_key: { to_table: :curator_institutions }, null: false
      t.string :name, null: false
      t.text :abstract, default: '', null: false
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
    end
  end
end
