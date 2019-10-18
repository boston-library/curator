FactoryBot.define do
  factory :curator_controlled_terms_genre, class: 'Curator::ControlledTerms::Genre' do
    authority_id { 1 }
    term_data { "" }
    type { "Curator::ControlledTerms::Genre" }
    archived_at { nil }
  end
end
