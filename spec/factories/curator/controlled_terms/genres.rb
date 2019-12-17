# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_genre, class: 'Curator::ControlledTerms::Genre' do
    association :authority, factory: :curator_controlled_terms_authority
    sequence(:term_data) do |_n|
      { label: Faker::Lorem.sentence,
        id_from_auth: Faker::Alphanumeric.alphanumeric(number: 10),
        basic: [true, false].sample }
    end
    type { 'Curator::ControlledTerms::Genre' }
    archived_at { nil }
  end
end
