# frozen_string_literal: true

class CreateCuratorDigitalObjects < ActiveRecord::Migration[5.2]
  def change
    create_table 'curator.digital_objects' do |t|
      t.string :ark_id, index: { using: :btree, unique: true }, null: false
      t.belongs_to :admin_set, index: { using: :btree }, foreign_key: { to_table: 'curator.collections' }, null: false
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
    end

    add_belongs_to 'curator.metastreams_descriptives', :digital_object, index: { unique: true, using: :btree, name: 'unique_idx_meta_desc_on_digital_object' }, foreign_key: { to_table: 'curator.digital_objects' }, null: false

    add_belongs_to 'curator.filestreams_file_sets', :file_set_of, index: { using: :btree, name: 'index_fstream_file_set_on_file_set_of_id' }, foreign_key: { to_table: 'curator.digital_objects' }, null: false

    add_belongs_to 'curator.digital_objects', :contained_by, index: { using: :btree, name: 'idx_digital_objects_on_contained_by' }, foreign_key: { to_table: 'curator.digital_objects', on_delete: :nullify }

    add_index 'curator.digital_objects', [:contained_by_id, :id], unique: true, where: 'contained_by_id is not null', name: 'unique_idx_digital_objects_on_contained_by_and_id', using: :btree
  end
end
