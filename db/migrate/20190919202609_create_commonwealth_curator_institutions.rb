class CreateCommonwealthCuratorInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_institutions do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.string :name, null: false
      t.text :abstract, default: ''
      t.integer :lock_version
      t.timestamps null: false
      t.boolean :archived, index: { using: :btree }, default: false, null: false
      t.index :archived, where: 'archived = false', using: :btree
  end
end
