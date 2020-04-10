# frozen_string_literal: true

FactoryBot.define do
  factory :curator_collection, class: 'Curator::Collection', aliases: [:collection] do
    ark_id
    with_metastreams
    association :institution, factory: :curator_institution
    name { "#{Faker::FunnyName.four_word_name} Collection" }
    abstract { Faker::Lorem.paragraph }

    trait :with_metastreams do
      administrative { nil }
      workflow { nil }

      after :build do |collection|
        collection.administrative = build(:curator_metastreams_administrative, administratable: collection) if collection.administrative.blank?
        collection.workflow = build(:curator_metastreams_workflow, workflowable: collection) if collection.workflow.blank?
      end
    end
  end
end
