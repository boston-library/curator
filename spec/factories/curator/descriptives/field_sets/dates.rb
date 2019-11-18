# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_date, class: 'Curator::Descriptives::Date' do
    created { Faker::Date.birthday(min_age: 95, max_age: 160).to_s }
    issued { Faker::Date.birthday(min_age: 80, max_age: 140).to_s }
    copyright { Faker::Date.birthday(min_age: 50, max_age: 90).to_s }
    skip_create
    initialize_with { new(attributes) }
  end
end
