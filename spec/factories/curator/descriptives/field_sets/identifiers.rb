# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_identifier, class: 'Curator::Descriptives::Identifier' do
    label { Faker::Lorem.sentence(word_count: 3) }
    type { Curator::Descriptives::IDENTIFIER_TYPES.sample }
    invalid { [true, false].sample }
    skip_create
    initialize_with { new(attributes) }
  end
end
