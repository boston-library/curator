# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_note, class: 'Curator::Descriptives::Note' do
    label { Faker::Lorem.sentence(word_count: 3) }
    type { Curator::Descriptives::NOTE_TYPES.sample }
    skip_create
    initialize_with { new(attributes) }
  end
end
