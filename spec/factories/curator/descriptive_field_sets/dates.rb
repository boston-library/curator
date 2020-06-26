# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_date, class: 'Curator::DescriptiveFieldSets::Date' do
    created do
      "#{Faker::Date.birthday(min_age: 159, max_age: 160).year}/#{Faker::Date.birthday(min_age: 150, max_age: 155).year}?"
    end
    issued { Faker::Date.birthday(min_age: 80, max_age: 140).to_s }
    copyright { Faker::Date.birthday(min_age: 50, max_age: 90).to_s }
    skip_create
    initialize_with { new(attributes) }
  end
end
