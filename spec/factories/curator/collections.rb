# frozen_string_literal: true

FactoryBot.define do
  factory :curator_collection, class: 'Curator::Collection' do
    ark_id
    association :institution, factory: :curator_institution
    name { "#{Faker::FunnyName.four_word_name} Collection" }
    abstract { Faker::Lorem.paragraph }
    archived_at { nil }

    trait :with_metastreams do
      after :create do |collection, _options|
        create(:curator_metastreams_administrative, administratable: collection)
        create(:curator_metastreams_workflow, workflowable: collection)
      end
    end
  end
end
