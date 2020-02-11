# frozen_string_literal: true

FactoryBot.define do
  factory :curator_metastreams_workflow, class: 'Curator::Metastreams::Workflow' do
    association :workflowable, factory: :curator_digital_object
    publishing_state { Curator::Metastreams::Workflow.publishing_states.keys.sample }
    processing_state { Curator::Metastreams::Workflow.processing_states.keys.sample }
    ingest_origin { Faker::Internet.uuid }
    archived_at { nil }
  end
end
