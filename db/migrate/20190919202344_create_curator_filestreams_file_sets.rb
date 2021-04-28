# frozen_string_literal: true

class CreateCuratorFilestreamsFileSets < ActiveRecord::Migration[5.2]
  def change
    create_table 'curator.filestreams_file_sets' do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.string :file_set_type, index: { using: :btree }, null: false
      t.string :file_name_base, null: false
      t.integer :position, index: { using: :btree, order: 'asc' }, null: false # Alias as Sequenece
      t.jsonb :pagination, index: { using: :gin, opclass: :jsonb_path_ops }, default: '{}'
      t.integer :lock_version
      t.timestamps null: false
    end
  end
end
