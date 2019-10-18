FactoryBot.define do
  factory :curator_controlled_terms_license, class: 'Curator::ControlledTerms::License' do
    authority_id { nil }
    term_data { "" }
    type { "Curator::ControlledTerms::License" }
    archived_at { nil }
  end
end
