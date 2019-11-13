# frozen_string_literal: true

FactoryBot.define do
  factory :curator_metastreams_workflow, class: 'Curator::Metastreams::Workflow' do
    association :workflowable, factory: :curator_digital_object
    publishing_state { 1 }
    processing_state { 1 }
    ingest_origin { Faker::Internet.uuid }
    archived_at { nil }
  end
end
