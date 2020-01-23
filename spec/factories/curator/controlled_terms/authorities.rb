# frozen_string_literal: true

FactoryBot.define do
  sequence :authority_code do |n|
    "loc-test-authority-#{n}"
  end

  sequence :authority_base_url do |n|
    Faker::Internet.url(host: 'loc.gov', path: "#{n}/loc-test-authority-#{n}.skos.json")
  end

  factory :curator_controlled_terms_authority, class: 'Curator::ControlledTerms::Authority' do
    code { generate(:authority_code) }
    name { Faker::Book.genre }
    base_url { generate(:authority_base_url) }
    archived_at { nil }
  end
end
