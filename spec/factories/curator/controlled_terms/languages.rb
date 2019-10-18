FactoryBot.define do
  factory :curator_controlled_terms_language, class: 'Curator::ControlledTerms::Language' do
    authority_id { 1 }
    term_data { "" }
    type { "Curator::ControlledTerms::Language" }
    archived_at { nil }
  end
end
