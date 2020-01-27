# frozen_string_literal: true

FactoryBot.define do
  factory :curator_collection, class: 'Curator::Collection' do
    association :institution, factory: :curator_institution
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(rand([n, 8].max..[n, 32].max))}" }
    name { "#{Faker::FunnyName.four_word_name} Collection" }
    abstract { Faker::Lorem.paragraph }
    archived_at { nil }

    trait :with_metastreams do
      after :create do |collection, options|
        create(:curator_metastreams_administrative, administratable: collection)
        create(:curator_metastreams_workflow, workflowable: collection)
      end
    end
  end
end
