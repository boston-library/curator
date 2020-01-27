# frozen_string_literal: true

FactoryBot.define do
  factory :curator_institution, class: 'Curator::Institution' do
    association :location, factory: :curator_controlled_terms_geographic
    sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(rand([n, 8].max..[n, 32].max))}" }
    name { Faker::University.name }
    abstract { Faker::Lorem.paragraph(sentence_count: 12) }
    url { Faker::Internet.unique.url(host: 'example-institution.org') }
    archived_at { nil }

    transient do
      collection_count { nil }
      with_collection_metastreams { false }
    end

    trait :with_location do
      location { create(:curator_controlled_terms_geographic) }
    end

    trait :with_metastreams do
      after :create do |institution|
        create(:curator_metastreams_administrative, administratable: institution)
        create(:curator_metastreams_workflow, workflowable: institution)
      end
    end

    after :create do |institution, options|
      if options.collection_count
        create_list(:curator_collection, options.collection_count, :with_metastreams, institution: institution) if options.with_collection_metastreams

        create_list(:curator_collection, options.collection_count, institution: institution) unless options.with_collection_metastreams
      end
    end
  end
end
