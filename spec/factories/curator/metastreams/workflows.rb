FactoryBot.define do
  factory :curator_metastreams_workflow, class: 'Curator::Metastreams::Workflow' do
    workflowable_type { "MyString" }
    workflowable_id { 1 }
    publishing_state { 1 }
    processing_state { 1 }
    ingest_origin { "MyString" }
    archived_at { nil }
  end
end
