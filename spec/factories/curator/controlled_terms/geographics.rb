FactoryBot.define do
  factory :curator_controlled_terms_geographic, class: 'Curator::ControlledTerms::Geographic' do
    authority_id { 1 }
    term_data { "" }
    type { "Curator::ControlledTerms::Geographic" }
    archived_at { nil}
  end
end
