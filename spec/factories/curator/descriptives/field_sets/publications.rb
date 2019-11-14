# frozen_string_literal: true

FactoryBot.define do
  factory :curator_descriptives_publication, class: 'Curator::Descriptives::Publication' do
    edition_name { Faker::Books::Lovecraft.deity }
    sequence(:edition_number) { |n| "#{n << 2}" }
    volume { %w(I X V L).sample }
    sequence(:issue_number) {|n| "#{n  << 2}" }
    skip_create
    initialize_with { new(attributes) }
  end
end
