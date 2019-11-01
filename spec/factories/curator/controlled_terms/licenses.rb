FactoryBot.define do
  factory :curator_controlled_terms_license, class: 'Curator::ControlledTerms::License' do
    term_data { { label: Faker::Lorem.sentence, uri: Faker::Internet.url } }
    type { 'Curator::ControlledTerms::License' }
    archived_at { nil }
  end
end
