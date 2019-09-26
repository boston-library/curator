# frozen_string_literal: true
class CreateCommonwealthCuratorMetastreamsWorkflows < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_metastreams_workflows do |t|
      t.belongs_to :workflowable, polymorphic: true, index: { unique: true, using: :btree, name: 'unique_idx_meta_workflows_on_metastreamable_poly'}, null: false
      t.integer :publishing_state, index: { using: :btree }, null: false, default: 0
      t.integer :processing_state, index: { using: :btree }, null: false, default: 0
      t.string :ingest_origin, null: false
      t.string :ingest_filepath, null: false
      t.string :ingest_filename, null: false
      t.string :ingest_datastream, null: false
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
    end
  end
end
