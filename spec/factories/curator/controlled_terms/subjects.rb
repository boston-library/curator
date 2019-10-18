FactoryBot.define do
  factory :curator_controlled_terms_subject, class: 'Curator::ControlledTerms::Subject' do
    authority_id { 1 }
    term_data { "" }
    type { 'Curator::ControlledTerms::Subject' }
    archived_at { nil }
  end
end
