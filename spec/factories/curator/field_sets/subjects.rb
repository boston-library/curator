# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_subject, class: 'Curator::FieldSets::Subject' do
    skip_create
    titles { create_list(:curator_descriptives_title, 3) }
    temporals { Faker::Lorem.words }
    dates { Array.new(3) { Faker::Date.birthday(min_age: 50, max_age: 90).year.to_s } }
    initialize_with { new(attributes) }
  end
end
