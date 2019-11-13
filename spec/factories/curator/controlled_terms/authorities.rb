# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_authority, class: 'Curator::ControlledTerms::Authority' do
    sequence(:code) { |n| "#{Faker::IndustrySegments.sector}-#{n}-#{n+1}-#{n+2}" }
    name { Faker::Book.genre }
    base_url { Faker::Internet.url(host: 'loc.gov') }
    archived_at { nil }
  end
end
