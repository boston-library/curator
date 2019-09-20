class CreateCommonwealthCuratorMetastreamsWorkflows < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_metastreams_workflows do |t|
      t.belongs_to :workflowable, polymorphic: true, index: { unique: true, using: :btree, name: 'unique_idx_meta_workflows_on_metastreamable_poly'}, null: false
      t.integer :publishing_state, index: { using: :btree }, null: false, default: 0
      t.integer :processing_state, index: { using: :btree }, null: false, default: 0
      t.string :ingest_origin
      t.string :ingest_filepath
      t.string :ingest_filename
      t.string :ingest_datastream
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :deleted_at, index: { using: :btree, where: 'deleted_at is null' }
    end
  end
end
