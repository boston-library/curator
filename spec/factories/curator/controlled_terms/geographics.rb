# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_geographic, class: 'Curator::ControlledTerms::Geographic' do
    association :authority, factory: :curator_controlled_terms_authority
    term_data { { label: Faker::Lorem.sentence, id_from_auth: Faker::Alphanumeric.alphanumeric(number: 10) } }
    type { 'Curator::ControlledTerms::Geographic' }
    archived_at { nil }
  end
end
