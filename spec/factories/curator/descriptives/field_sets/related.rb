# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_related, class: 'Curator::Descriptives::Related' do
    constituent { Faker::Name.name_with_middle }
    other_format { 2.times.map { Faker::Lorem.word }}
    referenced_by_url { 2.times.map { Faker::Internet.url(host: 'nrs.harvard.edu') } }
    references_url { 2.times.map { Faker::Internet.url } }
    review_url { 2.times.map { Faker::Internet.url(host: 'bpl.org' ) } }
    skip_create
    initialize_with { new(attributes) }
  end
end
