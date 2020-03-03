# frozen_string_literal: true

FactoryBot.define do
  factory :curator_digital_object, class: 'Curator::DigitalObject' do
    ark_id
    association :admin_set, factory: :curator_collection
    contained_by_id { nil }
    archived_at { nil }

    trait :with_contained_by do
      association :contained_by, factory: :curator_digital_object, strategy: :create
    end

    transient do
      desc_term_count { 1 }
    end

    after :build do |digital_object, options|
      build(:curator_metastreams_administrative, administratable: digital_object)
      build(:curator_metastreams_descriptive, :with_all_desc_terms, descriptable: digital_object, desc_term_count: options.desc_term_count)
      build(:curator_metastreams_workflow, workflowable: digital_object)
    end
  end
end
