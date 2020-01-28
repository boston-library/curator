# frozen_string_literal: true

FactoryBot.define do
  factory :curator_digital_object, class: 'Curator::DigitalObject' do
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(rand([n, 8].max..[n, 32].max))}" }
    association :admin_set, factory: :curator_collection
    contained_by_id { nil }
    archived_at { nil }

    trait :with_contained_by do
      association :contained_by, factory: :curator_digital_object, strategy: :create
    end

    trait :with_metastreams do
      transient do
        desc_term_count { nil }
      end

      after :create do |digital_object, options|
        create(:curator_metastreams_administrative, administratable: digital_object)
        create(:curator_metastreams_descriptive, :with_descriptive_fields, descriptable: digital_object, genre_count: options.desc_term_count, name_role_count: options.desc_term_count, resource_type_count: options.desc_term_count, language_count: options.desc_term_count, license_count: options.desc_term_count, subject_count: options.desc_term_count)
        create(:curator_metastreams_workflow, workflowable: digital_object)
      end
    end
  end
end
