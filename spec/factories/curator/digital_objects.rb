# frozen_string_literal: true

FactoryBot.define do
  factory :curator_digital_object, class: 'Curator::DigitalObject' do
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(rand([n, 8].max..[n, 32].max))}" }
    association :admin_set, factory: :curator_collection
    archived_at { nil }

    trait :with_metastreams do
      after :create do |digital_object|
        create(:curator_metastreams_administrative, administratable: digital_object)
        create(:curator_metastreams_descriptive, descriptable: digital_object)
        create(:curator_metastreams_workflow, workflowable: digital_object)
      end
    end
  end
end
