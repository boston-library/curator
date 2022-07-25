# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_related_title, class: 'Curator::DescriptiveFieldSets::RelatedTitle' do
    label { "The #{Faker::Lorem.word}" }
    control_number { Faker::Number.leading_zero_number(digits: 10) }
    skip_create
    initialize_with { new(attributes) }
  end
end
