class CreateCommonwealthCuratorInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_institutions do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :deleted_at, index: { using: :btree, where: 'deleted_at is null' }
    end
  end
end
