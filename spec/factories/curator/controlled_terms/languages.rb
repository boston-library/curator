FactoryBot.define do
  factory :curator_controlled_terms_language, class: 'Curator::ControlledTerms::Language' do
    association :authority, factory: :curator_controlled_terms_authority
    term_data { {label: Faker::Lorem.sentence, id_from_auth: Faker::Alphanumeric.alphanumeric(number: 10) } }
    type { 'Curator::ControlledTerms::Language' }
    archived_at { nil }
  end
end