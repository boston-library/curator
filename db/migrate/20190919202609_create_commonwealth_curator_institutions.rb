class CreateCommonwealthCuratorInstitutions < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_institutions do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.timestamps null: false
    end
  end
end
