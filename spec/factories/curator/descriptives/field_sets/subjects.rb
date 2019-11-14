# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_subject, class: 'Curator::Descriptives::Subject' do
    skip_create
    titles { create_list(:curator_descriptives_title, 3) }
    temporals { Faker::Lorem.words }
    dates { 3.times.map { Faker::Date.birthday(min_age: 50, max_age: 90).year.to_s } }
    initialize_with { new(attributes) }
  end
end
