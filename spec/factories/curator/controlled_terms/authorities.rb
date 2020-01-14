# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_authority, class: 'Curator::ControlledTerms::Authority' do
    sequence(:code) { |n| "#{Faker::IndustrySegments.sector}-#{n}-#{SecureRandom.hex(rand([n, 8].max..[n, 32].max))}" }
    name { Faker::Book.genre }
    base_url { Faker::Internet.unique.url(host: 'loc.gov') }
    archived_at { nil }
  end
end
