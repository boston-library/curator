# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_genre, class: 'Curator::ControlledTerms::Genre' do
    association :authority, factory: :curator_controlled_terms_authority
    term_data { { label: Faker::Lorem.sentence, id_from_auth: Faker::Alphanumeric.alphanumeric(number: 10) } }
    type { 'Curator::ControlledTerms::Genre' }
    archived_at { nil }
  end
end
