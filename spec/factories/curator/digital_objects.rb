# frozen_string_literal: true

FactoryBot.define do
  factory :curator_digital_object, class: 'Curator::DigitalObject' do
    ark_id
    with_metastreams
    association :admin_set, factory: :curator_collection

    trait :with_contained_by do
      association :contained_by, factory: :curator_digital_object, strategy: :create
    end

    transient do
      desc_term_count { 1 }
    end

    trait :with_metastreams do
      administrative { nil }
      descriptive { nil }
      workflow { nil }

      after :build do |digital_object, options|
        digital_object.administrative = build(:curator_metastreams_administrative, administratable: digital_object) if digital_object.administrative.blank?
        digital_object.descriptive = build(:curator_metastreams_descriptive, :with_all_desc_terms, desc_term_count: options.desc_term_count, descriptable: digital_object) if digital_object.descriptive.blank?
        digital_object.workflow = build(:curator_metastreams_workflow, workflowable: digital_object) if digital_object.workflow.blank?
      end
    end
  end
end
