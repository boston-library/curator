# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_license, class: 'Curator::ControlledTerms::License' do
    sequence(:term_data) { |_n| { label: Faker::Lorem.sentence, uri: Faker::Internet.url } }
    type { 'Curator::ControlledTerms::License' }
    archived_at { nil }
  end
end
