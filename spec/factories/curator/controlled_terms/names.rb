# frozen_string_literal: true

FactoryBot.define do
  factory :curator_controlled_terms_name, class: 'Curator::ControlledTerms::Name' do
    association :authority, factory: :curator_controlled_terms_authority
    sequence(:term_data) do |_n|
      { label: Faker::Lorem.sentence, id_from_auth: Faker::Alphanumeric.alphanumeric(number: 10) }
    end
    type { 'Curator::ControlledTerms::Name' }
    archived_at { nil }
  end
end
