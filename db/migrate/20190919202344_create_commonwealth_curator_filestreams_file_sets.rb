class CreateCommonwealthCuratorFilestreamsFileSets < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_filestreams_file_sets do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.belongs_to :fileset_of, polymorphic: true, index: { unique: true, using: :btree }, null: false
      t.integer :file_set_type, default: 0, index: { using: :btree }, null: false
      t.string :file_name_base, null: false
      t.string :page_label
      t.string :page_type
      t.integer :position, index: { using: :btree, order: 'postition asc' }, null: false #Alias as Sequenece
      t.jsonb :checksum_data, default: '{}', null: false
      t.integer :lock_version
      t.timestamps null: false
      t.boolean :archived, index: { using: :btree }, default: false, null: false
      t.index :position, order: 'position asc', using: :btree
      t.index :archived, where: 'archived = false', using: :btree
    end
  end
end
