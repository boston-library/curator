# frozen_string_literal: true

class CreateCuratorDigitalObjects < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_digital_objects do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.belongs_to :admin_set, index: { using: :btree }, foreign_key: { to_table: :curator_collections, on_delete: :cascade }, null: false
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
    end

    add_belongs_to :curator_filestreams_file_sets, :file_set_of, index: { using: :btree, name: 'index_fstream_file_set_on_file_set_of_id' }, foreign_key: { to_table: :curator_digital_objects, on_delete: :cascade }, null: false
  end
end
