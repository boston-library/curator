class CreateCommonwealthCuratorDigitalObjects < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_digital_objects do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.belongs_to :admin_set, index: { unique: true, using: :btree }, foreign_key: { to_table: :curator_collections }, null: false
      t.integer :lock_version
      t.timestamps null: false
    end
  end
end
