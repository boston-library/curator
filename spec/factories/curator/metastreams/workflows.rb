# frozen_string_literal: true

FactoryBot.define do
  factory :curator_metastreams_workflow, class: 'Curator::Metastreams::Workflow' do
    workflowable { nil }
    for_institution
    publishing_state { Curator::Metastreams::Workflow.publishing_states.keys.sample }
    processing_state { Curator::Metastreams::Workflow.processing_states.keys.sample }
    ingest_origin { Faker::Internet.uuid }

    trait :draft do
      publishing_state { :draft }
    end

    trait :for_institution do
      after :build do |workflow|
        workflow.workflowable = build(:curator_institution, workflow: workflow) if workflow.workflowable.blank?
      end
    end

    trait :for_collection do
      after :build do |workflow|
        workflow.workflowable = build(:curator_collection, workflow: workflow) if workflow.workflowable.blank?
      end
    end

    trait :for_digital_object do
      after :build do |workflow|
        workflow.workflowable = build(:curator_digital_object, workflow: workflow) if workflow.workflowable.blank?
      end
    end

    trait :for_file_set do
      transient do
        file_type { Curator.filestreams.file_set_types.map { |type| "curator_filestreams_#{type}".to_sym }.sample }
      end

      after :build do |workflow|
        workflow.workflowable = build(file_type, workflow: workflow) if workflow.workflowable.blank?
      end
    end
  end
end
