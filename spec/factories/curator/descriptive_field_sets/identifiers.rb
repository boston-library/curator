# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_identifier, class: 'Curator::DescriptiveFieldSets::Identifier' do
    label { Faker::Lorem.sentence(word_count: 3) }
    type { %w(local-filename local-other local-call local-barcode).sample }
    invalid { [true, false].sample }
    skip_create
    initialize_with { new(attributes) }
  end
end
