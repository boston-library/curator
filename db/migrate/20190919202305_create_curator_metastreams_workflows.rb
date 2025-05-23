# frozen_string_literal: true

class CreateCuratorMetastreamsWorkflows < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        create_enum 'curator.metastreams_workflow_publishing_state', %w(draft review published)
        create_enum 'curator.metastreams_workflow_processing_state', %w(initialized derivatives complete)

        create_table 'curator.metastreams_workflows' do |t|
          t.belongs_to :workflowable, polymorphic: true, index: { unique: true, using: :btree, name: 'unique_idx_meta_workflows_on_metastreamable_poly' }, null: false
          t.enum :publishing_state, enum_type: 'curator.metastreams_workflow_publishing_state', index: { using: :btree, name: 'idx_meta_workflow_on_publsihing_state' }, null: true
          t.enum :processing_state, enum_type: 'curator.metastreams_workflow_processing_state', index: { using: :btree, name: 'idx_meta_workflow_on_processing_state' }, null: true
          t.string :ingest_origin, null: false
          t.integer :lock_version
          t.timestamps null: false
        end

        dir.down do
          drop_table 'curator.curator_metastreams_workflows'
          drop_enum 'curator.metastreams_workflow_publishing_state'
          drop_enum 'curator.metastreams_workflow_processing_state'
        end
      end
    end
  end
end
