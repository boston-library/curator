# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_note, class: 'Curator::FieldSets::Note' do
    label { Faker::Lorem.sentence(word_count: 3) }
    type { %w(arrangement performers acquisition ownership).sample }
    skip_create
    initialize_with { new(attributes) }
  end
end
