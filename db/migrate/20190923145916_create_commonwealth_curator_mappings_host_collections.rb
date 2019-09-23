class CreateCommonwealthCuratorMappingsHostCollections < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mappings_host_collections do |t|
      t.string :name, null: false
      t.belongs_to :institution, index: { using: :btree }, foreign_key: { to_table: :curator_institutions }, null: false
      t.index [:name, :institution_id], unique: true, using: :btree
    end
  end
end
